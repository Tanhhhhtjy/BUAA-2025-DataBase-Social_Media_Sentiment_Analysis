# -*- coding: utf-8 -*-
import pymysql
import sys

# Force UTF-8 output
sys.stdout.reconfigure(encoding='utf-8')

config = {
    'host': '124.70.86.207',
    'port': 3306,
    'user': 'u23371020',
    'password': 'Aa048340',
    'database': 'h_db23371020',
    'charset': 'utf8mb4'
}

conn = pymysql.connect(**config)
cursor = conn.cursor()

print('=' * 60)
print('DATABASE TEST DATA SUMMARY')
print('=' * 60)

# Data counts
tables = ['users', 'posts', 'comments', 'hashtags', 'post_hashtags',
          'post_sentiments', 'keywords', 'alerts']
print('\n[Record Counts]')
for table in tables:
    cursor.execute(f'SELECT COUNT(*) FROM {table}')
    count = cursor.fetchone()[0]
    print(f'  {table:20}: {count:3} records')

# Users
print('\n' + '=' * 60)
print('[USERS]')
print('-' * 60)
cursor.execute('SELECT user_id, username, email, role, status FROM users')
for u in cursor.fetchall():
    print(f'  #{u[0]} {u[1]:12} | {u[2]:25} | {u[3]:5} | {u[4]}')

# Hashtags
print('\n' + '=' * 60)
print('[HASHTAGS]')
print('-' * 60)
cursor.execute('SELECT tag_name FROM hashtags')
tags = [r[0] for r in cursor.fetchall()]
print('  ' + ', '.join([f'#{t}#' for t in tags]))

# Keywords
print('\n' + '=' * 60)
print('[KEYWORDS for Alert Detection]')
print('-' * 60)
cursor.execute('SELECT keyword, category FROM keywords')
for k in cursor.fetchall():
    print(f'  "{k[0]}" - Category: {k[1]}')

# Sample Posts
print('\n' + '=' * 60)
print('[SAMPLE POSTS with Sentiment]')
print('-' * 60)
cursor.execute('''
    SELECT p.post_id, u.username, p.content, ps.sentiment, ps.confidence
    FROM posts p
    JOIN users u ON p.user_id = u.user_id
    LEFT JOIN post_sentiments ps ON p.post_id = ps.post_id
    ORDER BY p.post_id
    LIMIT 8
''')
for p in cursor.fetchall():
    sentiment = p[3] or 'N/A'
    confidence = f'{p[4]:.0%}' if p[4] else '-'
    content = p[2][:45] + '...' if len(p[2]) > 45 else p[2]
    print(f'  #{p[0]} [{sentiment:10} {confidence:>4}] @{p[1]}: {content}')

# Sentiment Distribution
print('\n' + '=' * 60)
print('[SENTIMENT DISTRIBUTION]')
print('-' * 60)
cursor.execute('''
    SELECT sentiment, COUNT(*) as cnt
    FROM post_sentiments
    GROUP BY sentiment
    ORDER BY cnt DESC
''')
for s in cursor.fetchall():
    bar = '█' * (s[1] // 2)
    print(f'  {s[0]:12}: {s[1]:3} {bar}')

# Recent Alerts
print('\n' + '=' * 60)
print('[RECENT ALERTS]')
print('-' * 60)
cursor.execute('''
    SELECT a.alert_id, a.content_type, k.keyword, a.summary, a.created_at
    FROM alerts a
    JOIN keywords k ON a.keyword_id = k.keyword_id
    ORDER BY a.created_at DESC
    LIMIT 5
''')
alerts = cursor.fetchall()
if alerts:
    for a in alerts:
        print(f'  [{a[1]}] Keyword: "{a[2]}" | {a[3][:30]}...')
else:
    print('  (No alerts)')

print('\n' + '=' * 60)
print('Test data check complete!')
print('=' * 60)

cursor.close()
conn.close()
