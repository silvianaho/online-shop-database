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

# get level 1 categories
l1_categories = mega_menu1.find_elements_by_xpath('//*[@level="L1"]')

# remove housebrand + tesco (explained by brand) and one level categories (newly added on 10 jun 2020)
l1_categories.pop(1)
del l1_categories[-4:]

l1_categories_item = []
l2_categories_item = []
l3_categories_item = []

for l1_no, l1 in enumerate(l1_categories):
    l1_categories_item += [l1.text]
    try:
        hover_l1 = action.move_to_element(l1_categories[l1_no]).perform()
        mega_desc = wait(driver, 5).until(lambda s: s.find_element_by_xpath('//*[@id="megaDescription"]').is_displayed())
        hover_desc = action.move_to_element(mega_desc).perform()
    except:
        pass

    soup = BeautifulSoup(driver.page_source, 'lxml')
    
    mega_menu2 = soup.find_all('div', {'data-testid': 'megaMenuL2Container'})

    l2_items = []
    l3_items = []

    for menu2 in mega_menu2:
        l2_categories = menu2.select('span[level="L2"]')
        
        for l2_item in l2_categories:
            l2_items += [l2_item.text]

            l3_categories = menu2.select('span[level="L3"]')
            l3_items_temp = []
            for l3_item in l3_categories:
                # ['Apples & Pears', 'Berries & Cherries', 'Kiwi & Grapes', 'Citrus Fruits', 'Stone Fruits', 'Tropical Fruits', 'Frozen Fruits']
                l3_items_temp += [l3_item.text]
            # [['Apples & Pears', 'Berries & Cherries', ... ], ['Asparagus & Sprouts', 'Beans, Peas & Nuts', ... ]]
            l3_items += [l3_items_temp]

    # [[['Apples & Pears', ... ], ['Asparagus & Sprouts', ... ]], [['Fresh Chicken', 'Frozen Chicken'], ['Fresh Pork', 'Frozen Pork']]]
    l3_categories_item += [l3_items]
    l2_categories_item += [l2_items]



# print(l3_categories_item)

insert_category = ""
# make the l1 insert values first
for index, item1 in enumerate(l1_categories_item):
    insert_category += "('{}', NULL),\n".format(item1)

# then make the l2 insert statement
# why? because we're using auto increment on the db :()
for index1, item1 in enumerate(l1_categories_item):
    for index2, item2 in enumerate(l2_categories_item[index1]):
        insert_category += "('{}', {}),\n".format(item2, index1 + 1)
    

# do the same for l3
temp_index = len(l1_categories_item)
for index1, item_arrays3 in enumerate(l3_categories_item):
    for index2, item_array3 in enumerate(item_arrays3):
        temp_index += 1
        for index3, item3 in enumerate(item_array3):
            insert_category += "('{}', {}),\n".format(item3, temp_index)


file = open("insertCategories.txt", "w")
file.write(insert_category)
file.close()


driver.close()
