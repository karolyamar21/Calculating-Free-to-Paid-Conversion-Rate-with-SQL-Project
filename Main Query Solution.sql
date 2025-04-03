-- i as student_info
-- e as Student_engagement
-- p as student_purchases

-- Subquery
USE db_course_conversions
SELECT 
    e.student_id,
    i.date_registered,
    MIN(e.date_watched) AS first_date_watched,
    MIN(p.date_purchased) AS first_date_purchased,
    DATEDIFF(MIN(e.date_watched), i.date_registered) AS days_diff_reg_watch,
    DATEDIFF(MIN(p.date_purchased), MIN(e.date_watched)) AS days_diff_watch_purch
FROM
student_engagement e
JOIN student_info i ON e.student_id = i.student_id
LEFT JOIN student_purchases p ON e.student_id = p.student_id
GROUP BY e.student_id
HAVING first_date_purchased IS NULL
    OR first_date_watched <= first_date_purchased;
    

-- Calculate the conversion rate: percentage of students who watched content and made a purchase
USE db_course_conversions;
SELECT ROUND(COUNT(first_date_purchased) / COUNT(first_date_watched),2) * 100 AS conversion_rate,
ROUND(SUM(days_diff_reg_watch) / COUNT(days_diff_reg_watch),2) AS av_reg_watch, -- average number of days between a student's registration and their first date watch
ROUND(SUM(days_diff_watch_purch) / COUNT(days_diff_watch_purch),2) AS av_watch_purch --  Average number of days between First date Watched and first date purchased
FROM
    (
    SELECT 
        e.student_id,
		i.date_registered,
		MIN(e.date_watched) AS first_date_watched, 
		MIN(p.date_purchased) AS first_date_purchased,
		DATEDIFF(MIN(e.date_watched), i.date_registered) AS days_diff_reg_watch,
		DATEDIFF(MIN(p.date_purchased), MIN(e.date_watched)) AS days_diff_watch_purch
    FROM student_engagement e
    JOIN student_info i ON e.student_id = i.student_id
    LEFT JOIN student_purchases p ON e.student_id = p.student_id -- Left join the student_purchases table to get purchase data (if it exists) for each student
    GROUP BY e.student_id
    HAVING first_date_purchased IS NULL
        OR first_date_watched <= first_date_purchased) a; -- Alias as 'a'
-- Conversion Rate is 11%
-- Average Watch is 3.42 to start watching a Lecture
-- Average Purchase is 26.25 to Purchase a Subcsciption from date of first engagement


-- Quiz Questions and Previous answers
-- When did a student with ID 268727 first watch a lecture
SELECT * FROM db_course_conversions.student_engagement
WHERE student_id = "268727"
-- 03/27/2022


SELECT * FROM db_course_conversions.student_purchases
WHERE student_id = "268727"
-- Did not purchase

-- This part is My Answer vs the correct Answer

-- What is the approximate average duration between the registration date and the date of first-time engagement?
WITH date_diffs AS (
    SELECT  
        student_id,  
        purchase_id,  
        date_registered,  
        MIN(date_watched) AS first_date_watched,  
        DATEDIFF(MIN(date_watched), date_registered) AS date_diff_reg_watch
    FROM db_course_conversions.free_to_paid_conversion  
    GROUP BY student_id, purchase_id, date_registered
    HAVING date_diff_reg_watch >= 0
)
SELECT AVG(date_diff_reg_watch) AS avg_reg_watch
FROM date_diffs
-- My answer is 8.9392 Correct answer is 3.42


-- What is the approximate average duration between the date of first-time engagement and the date of first-time purchase?
WITH date_diffs AS (
    SELECT  
        student_id,  
        purchase_id,  
        date_registered,
        MIN(date_watched) AS first_date_watched,
        MIN(date_purchased) as first_date_purchased,
        DATEDIFF(MIN(date_watched), MIN(date_purchased)) AS days_diff_watch_purch
    FROM db_course_conversions.free_to_paid_conversion  
    GROUP BY student_id, purchase_id, date_registered
    HAVING days_diff_watch_purch >= 0
)
SELECT AVG(days_diff_watch_purch) AS avg_days_purch
FROM date_diffs
-- My answer is 7.9459 correct anwer is 26.25

