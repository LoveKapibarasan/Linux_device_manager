from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

driver = webdriver.Firefox()
driver.get("https://hotspot.vodafone.de/bayern/")

# Verbinden ボタンが表示されてクリック可能になるまで待つ
verbinden_button = WebDriverWait(driver, 20).until(
    EC.element_to_be_clickable((By.XPATH, "//button[contains(text(), 'Verbinden')]"))
)

# ボタンをクリック
verbinden_button.click()
