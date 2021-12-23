""" Robot to enter weekly sales data into the RobotSpareBin Industries Intranet."""

import os

from Browser import Browser
from Browser.utils.data_types import SelectAttribute
from RPA.Excel.Files import Files
from RPA.FileSystem import FileSystem
from RPA.HTTP import HTTP
from RPA.PDF import PDF


Browser = browser()

def open_the_intranet_website():
    browser.open_browser("https://robotsparebinindustries.com/")

def log_in():
    browser.type_text("css:#username", "maria")
    browser.type_secret("css:#password", "thoushallnotpass")
    browser.click("text=Log in")



def main():
    print("Done.")


if __name__ == "__main__":
    main()
