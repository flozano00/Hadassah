SELECT  p.idnumber "ID #", p.first, p.last,
        PrefAdr.line1 "Preferred Line 1",   
        PrefAdr.line2 "Preferred Line 2",   
        PrefAdr.line3 "Preferred Line 3",   
        PrefAdr.city "Preferred City",   
        PrefAdr.state "Preferred State",   
        substr(PrefAdr.zip,1,5) "Preferred Zip", 
        PrefPhones.phonenumber Phone, 
        PrefE.email,
        PrefAdr.COUNTRY,
        TRUNC(MONTHS_BETWEEN(SYSDATE, ad.dob)/12) "Age",
        p.usercode6 "Chai Status:",
        TO_CHAR(p.usernumber1 , '$9,999.99') "Cum Giving" 


-----
FROM prospect p, 
-- Pref Addr
(SELECT idnumber, a.line1, a.line2, a.line3,   
               a.city, a.state, a.zip, a.COUNTRY  
 FROM address a  
 WHERE a.preference='Y' 
 AND (a.enddate IS NULL OR a.enddate > SYSDATE)) PrefAdr,  
-- Pref Phone
(SELECT idnumber, AREACODE || '-' || PHONE phonenumber  
    FROM phone p  
    WHERE p.preference='Y' AND (p.enddate IS NULL OR p.enddate > SYSDATE)   
     ) PrefPhones, 
-- Pref Email
(SELECT email, idnumber, preference, enddate 
  FROM   email 
  WHERE  preference='Y' AND (enddate IS NULL OR enddate > SYSDATE))PrefE,
--Additional_Demographics
 additional_demographics ad

/* They must have an address */
WHERE p.idnumber=PrefAdr.idnumber  
      AND p.idnumber = ad.idnumber(+)
      AND p.idnumber=PrefE.idnumber(+) 
      AND p.idnumber=PrefPhones.idnumber(+)
      AND p.idnumber < 90000000
--Here Shows Active Member.
      AND (p.usercode9 IN ('LIFE', 'ASSC')  OR (p.usercode9 = 'ANN' AND p.userdate2 > TRUNC(SYSDATE)-(1*365.24)))
      AND NOT EXISTS (select 'x' from additional_demographics a 
                      where a.idnumber=P.idnumber and a.deceased='Y')
--Criteria: Exclude individuals less then 18. And if they don’t have a birthdate include them.
      AND (TRUNC(MONTHS_BETWEEN(SYSDATE, ad.dob)/12) >= 18 OR ad.dob is NULL)
/*
   Gifts in the Gift table with an amount greater than 0.
   Updated: Frank Lozano 
 */
     AND (SELECT COUNT('x')
          FROM gift g
          WHERE g.idnumber = p.idnumber
          AND g.GIFTAMOUNT > 0 ) > 0 
/*
 No International Addresses
   
 */ 
      AND  (PrefAdr.country IS NULL OR PrefAdr.country IN ('USA','US'))
/* Exclude CHAI MEMBERS AND FORMAL CHAI MEMBERS */
      AND p.usercode6 is NULL
      AND p.usercode8 is NULL

/* usernumber1 = Cumulative giving either NULL or < $5000.00*/
      AND (p.usernumber1 < 5000 OR p.usernumber1 is NULL)
      AND p.solicit = 'Y'

-----
ORDER BY p.last, p.first;

/**
 *
 * Last Criteria : No solicitating
 */


