!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Sun Apr 30 01:09:16 2017
# Getting a List of Cryptocurrencies sorted by their most current Market Cap
"""
import pandas as pd
import json
from bs4 import BeautifulSoup
import requests
import os
from datetime import datetime, date, time, timedelta
today = datetime.today()
mm=today.month
yy = today.year
# 1. GET LIST OF CRYPTOCURRENCIES BY MARKET CAP
#You can set your own paths here to save a text file with the list of coins
datapath=desktop = os.path.expanduser("~/Desktop/")
dataPath=os.path.join(desktop,'Data/Cryptocompare_Crypto/')
url = "https://api.coinmarketcap.com/v1/ticker/";
response = requests.get(url)
soup = BeautifulSoup(response.content, "html.parser")
dic = json.loads(soup.prettify())
# create an empty DataFrame
df = pd.DataFrame(columns=["Ticker", "MarketCap"])
for i in range(len(dic)):
    df.loc[len(df)] = [dic[i]['symbol'], dic[i]['market_cap_usd']]
df.sort_values(by=['MarketCap'])
# apply conversion to numeric as 'df' contains lots of 'None' string as values
df.MarketCap = pd.to_numeric(df.MarketCap)
fileName="CryptoTickersByCap_"+str(mm) +"_"+str(yy) + ".txt"
P = df[df.MarketCap > 20e6]  # This will list any coins with cap>20 mill. You can customize this threshold number
P.to_csv(os.path.join(dataPath,fileName),",");
#print(P)#, end="\n\n")
portfolio = list(P.Ticker)
print(portfolio)
