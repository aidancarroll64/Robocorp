*** Settings ***
Documentation     Build and order robots from RobotSpareBin website.
...               Save the order receipt as a PDF file.
...               Save a screenshot of the ordered robot.
...               Embed the screenshot of the robot to the PDF receipt.
...               Create a ZIP archive of the receipts and images.
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.Tables
Library           RPA.HTTP
Library           RPA.PDF
Library           RPA.Desktop

*** Variables ***
${URL}=           https://robotsparebinindustries.com/#/robot-order
${GLOBAL_RETRY_AMOUNT}=    3x
${GLOBAL_RETRY_INTERVAL}=    1s

*** Tasks ***
Build and order robot on RSB website.
    Open RSB robot order website
    ${order_numbers}=    Download and read excel file
    FOR    ${order_number}    IN    @{order_numbers}
        Close pop-up
        Fill data for one order    ${order_number}
        Preview robot
        Submit order and keep checking until successful
        ${pdf}=    Store receipt in PDF    ${order_number}
        ${screenshot}=    Take screenshot of robot    ${order_number}
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Order another robot
    END
    # Create ZIP file of all PDFs

*** Keywords ***
Open RSB robot order website
    Open Available Browser    ${URL}

Close pop-up
    Click Button    OK

Download and read excel file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    Read table from CSV    orders.csv
    ${order_numbers}=    Read table from CSV    orders.csv    header=True
    [Return]    ${order_numbers}

Fill data for one order
    [Arguments]    ${order_number}
    Select From List By Value    head    ${order_number}[Head]
    Click Button    id:id-body-${order_number}[Body]
    Input Text    css:input.form-control    ${order_number}[Legs]
    Input Text    address    ${order_number}[Address]

Preview robot
    Click Button    preview

Submit order and keep checking until successful
    Wait Until Keyword Succeeds    ${GLOBAL_RETRY_AMOUNT}    ${GLOBAL_RETRY_INTERVAL}    Submit robot order

 Submit robot order
    Click Button    order
    Wait Until Page Contains Element    id:receipt
    Log To Console    Submit successful

Store receipt in PDF
    [Arguments]    ${order_number}
    Wait Until Element Is Visible    id:receipt
    ${receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt_html}    ${OUTPUT_DIR}${/}robot_receipt_${order_number}[Order number].pdf
    # ${pdf}=    Html To Pdf    ${receipt_html}    C:/Users/Aidan/Documents/Robocorp/receipts${/}robot_receipt${order_number}[Order number].pdf
    [Return]    ${OUTPUT_DIR}${/}robot_receipt_${order_number}[Order number].pdf

Take screenshot of robot
    [Arguments]    ${order_number}
    Screenshot    id:robot-preview    ${OUTPUT_DIR}${/}robot_screenshot_${order_number}[Order number].png
    # ${screenshot}=    Screenshot    id:robot-preview    C:/Users/Aidan/Documents/Robocorp/screenshots${/}robot_screenshot_${order_number}[Order number].png
    [Return]    ${OUTPUT_DIR}${/}robot_screenshot_${order_number}[Order number].png

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    ${screenshot_file}=    Create List    ${screenshot}
    Add Files To Pdf    ${screenshot_file}    ${pdf}    TRUE

Order another robot
    Click Button    order-another
