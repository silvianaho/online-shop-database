from selenium import webdriver
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.support.ui import WebDriverWait as wait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
import time
import pandas as pd
from bs4 import BeautifulSoup

electronics_URL = 'https://www.fairprice.com.sg/category/electronics-appliances'
eit_URL = 'https://www.fairprice.com.sg/category/electronics-it-gadgets?sorting=A-Z'
adaptor_URL = 'https://www.fairprice.com.sg/category/extensions-adaptors?sorting=A-Z'


def scroll(driver, timeout):
    scroll_pause_time = timeout

    # Get scroll height
    last_height = driver.execute_script("return document.body.scrollHeight")

    while True:
        # Scroll down to bottom
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")

        # Wait to load page
        time.sleep(scroll_pause_time)

        # Calculate new scroll height and compare with last scroll height
        new_height = driver.execute_script("return document.body.scrollHeight")
        if new_height == last_height:
            # If heights are the same it will exit the function
            break
        last_height = new_height

def get_brands(url):
    # Setup the driver. 
    path_to_driver = "D:\SP SEM 3\ST1501 - DATA ENGINEERING\CA1\Data\chromedriver_win32\chromedriver.exe"
    driver = webdriver.Chrome(path_to_driver)

    # implicitly_wait tells the driver to wait before throwing an exception
    # driver.implicitly_wait(30)
    
    # driver.get(url) opens the page
    driver.get(url)

    # Once scroll returns bs4 parsers the page_source
    soup_a = BeautifulSoup(driver.page_source, 'lxml')
    
    # Them we close the driver as soup_a is storing the page source
    driver.close()

    brands = []
    
    brand_filter = soup_a.select("div[data-testid='filterList-desktop-brand']")
    brand_list = brand_filter[0].select('span.dyhHCc')

    for brand in brand_list:
        brands.append(brand.text)

    return brands

def get_products(url):
    # Setup the driver. 
    path_to_driver = "D:\SP SEM 3\ST1501 - DATA ENGINEERING\CA1\Data\chromedriver_win32\chromedriver.exe"
    driver = webdriver.Chrome(path_to_driver)

    # driver.get(url) opens the page
    driver.get(url)
    
    # This starts the scrolling by passing the driver and a timeout
    scroll(driver, 5)
    
    # Once scroll returns bs4 parsers the page_source
    soup_a = BeautifulSoup(driver.page_source, 'lxml')
    
    # Them we close the driver as soup_a is storing the page source
    driver.close()

    # Empty array to store the data
    product_name = []
    measurements = []
    base_price = []
    instock = []


    # Looping through all the targeted elements in the page source
    for item in soup_a.select("div[data-testid='product']"):
        for name in item.select('div.hUHyCH > span'):
            product_name.append(name.text)

        for measurement in item.find_all('span', {'class': 'givUAo'}):
            measurements.append(measurement.text)

        for price in item.find_all('div', {'class': 'heTVFR'}):
            if price.select('button'):
                pass
            elif price.select('del'):
                non_discount = price.select('del.fSxaiS')
                base_price.append(non_discount[0].text)
            elif price.select('span.dQYxgv'):
                non_discount = price.select('span.dQYxgv')
                base_price.append(non_discount[0].text)
        
        if item.select('div.sc-1axwsmm-4'):
            instock.append(1)
        else:
            instock.append(0)
    
    return product_name, measurements, base_price, instock

brands = get_brands(electronics_URL)
adaptor_product_name, adaptor_measurements, adaptor_base_price, adaptor_instock = get_products(adaptor_URL)
eit_product_name, eit_measurements, eit_base_price, eit_instock = get_products(eit_URL)

insert_brands = ""

adaptor_brand = []
eit_brand = []

# ifan is part of powerpac
brands.pop(0)
adaptor_product_name.pop(0)
adaptor_measurements.pop(0)
adaptor_base_price.pop(0)
adaptor_instock.pop(0)

first_category = 37

# insert brand values
for b_index, brand in enumerate(brands, start=1):
    insert_brands += "('{}'),\n".format(brand.lower())

    for index, name in enumerate(adaptor_product_name, start=1):
        product_brand = name.split(' ', 1)[0].lower()
        if product_brand == brand.split(' ', 1)[0].lower():
            adaptor_brand.append(first_category + b_index)

    for index, name in enumerate(eit_product_name, start=1):
        product_brand = name.split(' ', 1)[0].lower()
        if product_brand == brand.split(' ', 1)[0].lower():
            eit_brand.append(first_category + b_index)


# insert values
current_index = 249

insert_products = ""
insert_price = ""



for name, measurement, price, instock, brand in zip(adaptor_product_name, adaptor_measurements, adaptor_base_price, adaptor_instock, adaptor_brand):
    current_index += 1
    desc = ''
    for word in name.split(' ')[1:]:
        desc += word + ' '
    insert_products += "('{}', '{}', '{}', 1, {}, {}, 537),\n".format(name, desc, measurement, instock, brand)
    insert_price += "({}, {}, '01/01/20 00:00:00', 1),\n".format(current_index, price.split('$')[1])

for name, measurement, price, instock, brand in zip(eit_product_name, eit_measurements, eit_base_price, eit_instock, eit_brand):
    current_index += 1
    desc = ''
    for word in name.split(' ')[1:]:
        desc += word + ' '
    insert_products += "('{}', '{}', '{}', 1, {}, {}, 526),\n".format(name, desc, measurement, instock, brand)
    insert_price += "({}, {}, '01/01/20 00:00:00', 1),\n".format(current_index, price.split('$')[1])

file = open("insertElectronicProducts.txt", "w")
file.write(insert_products)
file.close()

file = open("insertElectronicPricing.txt", "w")
file.write(insert_price)
file.close()

file = open("insertElectronicBrands.txt", "w")
file.write(insert_brands)
file.close()
