import requests
import bs4
from bs4 import BeautifulSoup
import numpy as np

url = "https://www.fairprice.com.sg/categories"
headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.97 Safari/537.36"}
result = requests.get(url, headers=headers)
print(result.status_code)
# print(result.content.decode()

src = result.content.decode()
soup = BeautifulSoup(src, 'lxml')
# print(soup)

level1_category = []
level2_category = []
level3_category = []

paragraphs = soup.find_all("p")
for p in paragraphs:
    level1_category += p.text

links = soup.select("a[data-testid = 'sub-category-item']")
for a in links:
    level2_category += a.text

# divs = soup.find('div', {'class': 'vadqj-1 begMQy'})
# print(divs)

scripts = soup.find_all("script")
print(scripts)


# spans = soup.find_all('span')
# cat1
# list_of_classes = []
# for span in spans:
    # print(span.text, span.attrs["class"])
    # list_of_classes += span.attrs["class"]

# print(np.unique(list_of_classes))

# level1_category = soup.find_all("div", {"class": "sc-1bsd7ul-0 vadqj-5 eDhAYJ"})
# print(level1_category)


# l1_class = 'sc-1bsd7ul-0'
# l2_class = 'sc-2tygza-2'
# sc-1bsd7ul-0
# for span in spans:
#     if l1_class in span.attrs["class"]:
#         level1_category += span.text
#         print(span.text)
#     elif l2_class in span.attrs["class"]:
#         print(span.text)
#         level2_category += span.text
#     elif "" in span.attrs["class"]:
#         level3_category += span.text
# print(level1_category)
# print("------------000000000------------------")
# print(level2_category)
