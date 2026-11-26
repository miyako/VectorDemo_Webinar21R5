// Follow the OS language: Japanese on a Japanese system, English otherwise.
var $language:=Get database localization(User system localization)
SET DATABASE LOCALIZATION(($language="ja@") ? "ja" : "en")

TicketFinder
