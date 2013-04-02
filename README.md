pesit_confessions
=================

some hacks around fb/pesit_confessions

Instructions:

Uses redis as the backend(port 6379 hardcoded at the moment)
stores confession number as the key and message,no_of likes, no_of comments, comments as values

Sample redis entry
hset "posts" "3" "{\"message\": message, \"likes\": 3, \"comments_count\": 3, \"comments\" :[c1, c2, c3]}"

You can use this project to scrape pesit_confessions page and store it in redis
in the following format. You can then process this data in your own project by
connection to redis at 6379 port.
