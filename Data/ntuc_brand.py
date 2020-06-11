import requests
from bs4 import BeautifulSoup
import pandas as pd


url = "https://www.fairprice.com.sg/brands"
headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.97 Safari/537.36"}
result = requests.get(url, headers=headers)
print(result.status_code)
# print(result.content.decode()

src = result.content.decode()
soup = BeautifulSoup(src, 'lxml')

brands = soup.find_all('span', {"class": "r1k0d8-4"})


brands_list = ""
for brand in brands:
    brands_list += "('{}'),\n".format(brand.text)


file = open("insertBrands.txt", "w")
file.write(brands_list)
file.close()
