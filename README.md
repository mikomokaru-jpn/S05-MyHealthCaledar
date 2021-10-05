## macOS S05-MyHealthCaledar

## Blood pressure management calendar

Confirmed operation: macOS 10.14.6 / Xcode 11.3.1 

Enter your daily blood pressure into the calendar to help your health.

## How to enter blood pressure

To open the blood pressure input sheet for a specific day, select a day of the calendar which will be enclosed in blue border and press input button, or double-click that day.

Enter blood pressure by pressing numbers on the blood pressure input sheet or the keyboard. If you set confirmation flag to true and perform registration, the blood pressure data will be registered in the database. If confirmation flag is turned off, the data will be registered, but the input operation status is to be incomplete

<img src="http://mikomokaru.sakura.ne.jp/data/B18/calendar1.png" alt="calendar" title="calendar1" width="300">

## Display of a monthly blood pressure list

Click list display button to display a list of blood pressure for the month. Each blood pressure are graphed so that You can grasp the status at a glance. If you have high blood pressure which is above normal value, the color of the text and the graph are changed.

<img src="http://mikomokaru.sakura.ne.jp/data/B18/calendar2.png" alt="calendar" title="calendar2" width="300">

## Application design

It is a client / server method. The application sends an HTTP request to the server, and the server returns JSON-formatted response data. The database is implemented in MySQL, and data is referenced and updated with PHP scripts.
* Webサーバー：Apache2.4 & PHP5.6
* データベース：MySQL5.7
