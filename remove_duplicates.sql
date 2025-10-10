-- Direct SQL to remove all duplicate menu items
-- Run this directly in your Supabase SQL editor

-- First, remove all variations and add-ons for duplicates
DELETE FROM variations 
WHERE menu_item_id IN (
  SELECT id FROM menu_items 
  WHERE name IN (
    SELECT name FROM menu_items 
    WHERE category = 'Starters'
    GROUP BY name 
    HAVING COUNT(*) > 1
  )
);

DELETE FROM add_ons 
WHERE menu_item_id IN (
  SELECT id FROM menu_items 
  WHERE name IN (
    SELECT name FROM menu_items 
    WHERE category = 'Starters'
    GROUP BY name 
    HAVING COUNT(*) > 1
  )
);

-- Now remove all duplicate menu items, keeping only the first one alphabetically
DELETE FROM menu_items 
WHERE category = 'Starters'
AND id NOT IN (
  SELECT DISTINCT ON (name) id 
  FROM menu_items 
  WHERE category = 'Starters'
  ORDER BY name, id ASC
);

-- Show remaining starter items to verify
SELECT name, base_price, popular, created_at 
FROM menu_items 
WHERE category = 'Starters' 
ORDER BY name;
