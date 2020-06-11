import requests
import bs4
from bs4 import BeautifulSoup

# print("requests version: {}".format(requests.__version__)) # 2.23.0
# print("beautifulsoup version: {}".format(bs4.__version__)) # 4.9.1


# using the requests module, we use the "get" function provided 
# to access the webpage provided as an argument
result = requests.get("https://www.google.com")

# To make sure that the website is accessible, 
# we can ensure that we obtain a 200 OK response
# to indicate that the page is indeed present:
print(result.status_code)

# we can also check the HTTP header of the website 
# to verify that we have access the correct page:
# print(result.headers) 

# Now, let us store the page content of the website accessed 
# from requests to a variable
src = result.content
# apparently, this is the html file lol

# Now that we have the page source stored, we will use the 
# BeautifulSoup module to parse & process the source.
# To do so, we can create a BeautifulSoup object based on the
# source variable we created above:
soup = BeautifulSoup(src, 'lxml')
# print(soup)

# Now that the page source has been processed via BeautifulSoup
# we can access specific info directly from it. For instance,
# say we want to see a list of all of the links on the page:
links = soup.find_all("a")
# print(links)
# print()

# Perhaps we just want to extract the link that contains the text 
# "About" on the page instead of every link. We can use the built-in 
# "text" function to access the text content between the <a> </a> tags
for link in links:
    if "About" in link.text:
        print(link)
        print(link.attrs['href'])


    