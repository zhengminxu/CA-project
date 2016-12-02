# coding: utf-8

from sys import argv
import string
import nltk
import re
import numpy as np
from nltk.stem.snowball import SnowballStemmer
from nltk.tokenize import RegexpTokenizer
import csv
import gensim, logging
from sklearn.metrics.pairwise import cosine_similarity

stemmer = SnowballStemmer("english")

def normalize_docs(doc_name, stem = 1):    
    with open(doc_name, 'r') as doc:
        norm_doc = doc.read().decode('utf-8')
        sens = [sent for sent in nltk.sent_tokenize(norm_doc)]
        sens_token = [title_tokenizer(sent,stem) for sent in sens]
    return sens_token
    
def normalize_titles(doc_name, stem = 1):    
    with open(doc_name, 'r') as doc:
        norm_doc = doc.read().decode('utf-8')
        sens = [sent for sent in norm_doc.splitlines()]
        sens_token = [title_tokenizer(sent, stem) for sent in sens]
    return sens_token
    
def title_tokenizer(text, stem = 1):
    tokenizer = RegexpTokenizer(r'[a-z]+')
    title = tokenizer.tokenize(text.lower())
    if stem:
        texts = [stemmer.stem(t) for t in title]
    else:
        texts = title
    stopwords = nltk.corpus.stopwords.words('english')
    tokens = [word for word in texts if word not in stopwords]
    return tokens

def output_to_csv(csv_title, arr, output):
    ans = open(output, 'w')
    writer = csv.writer(ans)
    writer.writerow(["ID", "Ans"])
    with open(csv_title, 'rb') as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        i = 0
        reader.next()
        for row in reader:
            if arr[int(row[1])] == arr[int(row[2])] or (arr[int(row[1])] in [14,20] and 
                arr[int(row[2])] in [14,20]):
                writer.writerow([i, 1])
            else:
                writer.writerow([i, 0])
            i += 1


script, path, output_title = argv
#path = '/Users/Quizas/exercise/ML/hw4/data/'
if not path.endswith('/'):
    path += '/'
doc_name = path + 'docs.txt'
titles_name = path + 'title_StackOverflow.txt'
sens = normalize_docs(doc_name)
sens1 = normalize_titles(titles_name)
all_sens = sens1 + sens


# word2vec model
logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s', level=logging.INFO)
model = gensim.models.Word2Vec(all_sens, size = 200, min_count = 5, workers = 4)


# find topics
titles = open(titles_name, 'r').read().decode('utf-8').splitlines()
title_nnp = []
for title in titles:
    nnp = [stemmer.stem(word.lower()) for word, pos in nltk.pos_tag(nltk.word_tokenize(title)) if pos in ['NNP', 'NNPS'] and 
           word not in string.punctuation]
    title_nnp.append(nnp)
nnp_model = gensim.models.Word2Vec(title_nnp, size = 200, min_count = 200, workers = 4)
nnp_vocab = [k for (k, v) in nnp_model.vocab.iteritems()]
nnp_vocab = [item for item in nnp_vocab if item not in ['x', 'os']]


# filter out ambiguous words
stopwords1 = ['window', 'vista', 'winxp', 'sql', 'x']
fil_sens1 = []
for title in sens1:
    fil = [word for word in title if word not in stopwords1]
    fil_sens1.append(fil)

# vectorize titles
title_arr = np.zeros((len(fil_sens1), 200))
for i, title in enumerate(fil_sens1):
    for word in title:
        try:
            vec = model[word]
        except KeyError:
            vec = np.zeros((200,))
        title_arr[i] += vec
    if np.sum(title_arr[i]) == 0:
        title_arr[i] = model['cocoa'] # randomly pick a topic

# vectorize topics
nnp_arr = np.zeros((len(nnp_vocab), 200))
for i, word in enumerate(nnp_vocab):
    nnp_arr[i] = model[word]

# cluster by cosine similarity
labels = []
for title, title_vec in zip(fil_sens1, title_arr):
    candidates = [word for word in title if word in nnp_vocab]
    if len(candidates) != 0:
        sim = [cosine_similarity([title_vec], [model[word]])[0][0] for word in candidates]
        labels.append(nnp_vocab.index(candidates[sim.index(max(sim))]))
    else:
        sim = [cosine_similarity([title_vec], [nnp_vec])[0][0] for nnp_vec in nnp_arr]
        labels.append(sim.index(max(sim)))

# output answers
csv_title = path + 'check_index.csv'
output_to_csv(csv_title, labels, output_title)