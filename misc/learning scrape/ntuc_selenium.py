from selenium import webdriver
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.support.ui import WebDriverWait as wait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
import time
import pandas as pd
from bs4 import BeautifulSoup


path_to_driver = "D:\SP SEM 3\ST1501 - DATA ENGINEERING\CA1\Data\chromedriver_win32\chromedriver.exe"
URL = 'https://www.fairprice.com.sg/categories'
driver = webdriver.Chrome(path_to_driver)

driver.get(URL)

action = ActionChains(driver)

cat_nav = driver.find_element_by_xpath('//*[@title="Categories"]')

hover_cat_nav = action.move_to_element(cat_nav).perform()
mega_menu1 = driver.find_element_by_xpath('//*[@data-testid="megaMenuL1Container"]')
l1_categories = mega_menu1.find_elements_by_xpath('//*[@level="L1"]')

l1_categories_item = []
l2_categories_item = []
l3_categories_item = []

for l1_no, l1 in enumerate(l1_categories):
    l1_categories_item += [l1.text]
    try:
        hover_l1 = action.move_to_element(l1_categories[l1_no]).perform()
        mega_menu2 = wait(driver, 5).until(lambda s: s.find_element_by_xpath('//*[@data-testid="megaMenuL2Container"]').is_displayed())
        hover_menu2 = action.move_to_element(mega_menu2).perform()
    except:
        pass

    soup = BeautifulSoup(driver.page_source, 'lxml')
    l2_categories = soup.select('span[level="L2"]')
    l2_items = []
    for l2_item in l2_categories:
        l2_items += [l2_item.text]

    l2_categories_item += [l2_items]

    l3_categories = soup.select('span[level="L3"]')
    l3_items = []
    for l3_item in l3_categories:
        l3_items += [l3_item.text]

    l3_categories_item += [l3_items]


# remove housebrand (explained by brand) and one level categories (newly added on 10 jun 2020)
l1_categories_item.pop(1)
l2_categories_item.pop(1)
l3_categories_item.pop(1)
del l1_categories_item[-3:]


insert_l1_l2 = ""
insert_l3 = ""
# make the l1 insert values first
for index, item1 in enumerate(l1_categories_item):
    insert_l1_l2 += "('{}', NULL),\n".format(item1)

# then make the l2 insert statement
# why? because we're using auto increment on the db :()
for index, item1 in enumerate(l1_categories_item):
    for item2 in l2_categories_item[index]:
        insert_l1_l2 += "('{}', {}),\n".format(item2, index + 1)
    
    # item3 on the same level as item2 because there's no way to group item3 under level2, yet 
    for item3 in l3_categories_item[index]:
        insert_l3 += "('{}', {}),\n".format(item3, index + 1)

file = open("insertL1L2.txt", "w")
file.write(insert_l1_l2)
file.close()

file = open("insertL3.txt", "w")
file.write(insert_l3)
file.close()


driver.close()
