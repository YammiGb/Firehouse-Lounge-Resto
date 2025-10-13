-- Create Tables and Add Firehouse Lounge & Resto Menu Items
-- This migration creates all necessary tables and adds the complete menu

-- First, remove any existing duplicates to ensure clean data
DELETE FROM variations 
WHERE menu_item_id IN (
  SELECT id FROM menu_items 
  WHERE name IN (
    SELECT name FROM menu_items 
    GROUP BY name 
    HAVING COUNT(*) > 1
  )
);

DELETE FROM add_ons 
WHERE menu_item_id IN (
  SELECT id FROM menu_items 
  WHERE name IN (
    SELECT name FROM menu_items 
    GROUP BY name 
    HAVING COUNT(*) > 1
  )
);

DELETE FROM menu_items 
WHERE id NOT IN (
  SELECT DISTINCT ON (name) id 
  FROM menu_items 
  ORDER BY name, created_at ASC
);

DELETE FROM variations 
WHERE id NOT IN (
  SELECT DISTINCT ON (menu_item_id, name) id 
  FROM variations 
  ORDER BY menu_item_id, name, created_at ASC
);

DELETE FROM add_ons 
WHERE id NOT IN (
  SELECT DISTINCT ON (menu_item_id, name) id 
  FROM add_ons 
  ORDER BY menu_item_id, name, created_at ASC
);

/*
  # Create Menu Management System

  1. New Tables
    - `menu_items`
      - `id` (uuid, primary key)
      - `name` (text)
      - `description` (text)
      - `base_price` (decimal)
      - `category` (text)
      - `popular` (boolean)
      - `available` (boolean)
      - `image_url` (text, optional)
      - `discount_price` (decimal, optional)
      - `discount_start_date` (timestamp, optional)
      - `discount_end_date` (timestamp, optional)
      - `discount_active` (boolean)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)
    
    - `variations`
      - `id` (uuid, primary key)
      - `menu_item_id` (uuid, foreign key)
      - `name` (text)
      - `price` (decimal)
      - `created_at` (timestamp)
    
    - `add_ons`
      - `id` (uuid, primary key)
      - `menu_item_id` (uuid, foreign key)
      - `name` (text)
      - `price` (decimal)
      - `category` (text)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on all tables
    - Add policies for public read access
    - Add policies for authenticated admin access
*/

-- Create menu_items table
CREATE TABLE IF NOT EXISTS menu_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text NOT NULL,
  base_price decimal(10,2) NOT NULL,
  category text NOT NULL,
  popular boolean DEFAULT false,
  available boolean DEFAULT true,
  image_url text,
  discount_price decimal(10,2),
  discount_start_date timestamptz,
  discount_end_date timestamptz,
  discount_active boolean DEFAULT false,
  sort_order integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Add sort_order column if it doesn't exist (for existing tables)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'menu_items' AND column_name = 'sort_order'
  ) THEN
    ALTER TABLE menu_items ADD COLUMN sort_order integer DEFAULT 0;
  END IF;
END $$;

-- Update sort_order for existing Starters items
UPDATE menu_items SET sort_order = 1 WHERE name = 'Cheesy Nachos' AND category = 'Starters';
UPDATE menu_items SET sort_order = 2 WHERE name = 'Taco Bites' AND category = 'Starters';
UPDATE menu_items SET sort_order = 3 WHERE name = 'French Fries' AND category = 'Starters';
UPDATE menu_items SET sort_order = 4 WHERE name = 'Mojitos' AND category = 'Starters';
UPDATE menu_items SET sort_order = 5 WHERE name = 'Snack Platter' AND category = 'Starters';
UPDATE menu_items SET sort_order = 6 WHERE name = 'Cheese Quesadilla' AND category = 'Starters';
UPDATE menu_items SET sort_order = 7 WHERE name = 'TORTIZZA' AND category = 'Starters';
UPDATE menu_items SET sort_order = 8 WHERE name = 'Double Cheese Bread' AND category = 'Starters';
UPDATE menu_items SET sort_order = 9 WHERE name = 'Onion Rings' AND category = 'Starters';
UPDATE menu_items SET sort_order = 10 WHERE name = 'Chicken n'' Fish Chips' AND category = 'Starters';

-- Update sort_order for existing Salad items
UPDATE menu_items SET sort_order = 1 WHERE name = 'Green Tossed Salad' AND category = 'Salads';
UPDATE menu_items SET sort_order = 2 WHERE name = 'Firehouse Salad' AND category = 'Salads';
UPDATE menu_items SET sort_order = 3 WHERE name = 'Paradise Salad' AND category = 'Salads';

-- Update sort_order for existing Burger items
UPDATE menu_items SET sort_order = 1 WHERE name = 'Classic Burger' AND category = 'Burgers';
UPDATE menu_items SET sort_order = 2 WHERE name = 'Bacon & Mushroom' AND category = 'Burgers';
UPDATE menu_items SET sort_order = 3 WHERE name = 'Jalapeno' AND category = 'Burgers';
UPDATE menu_items SET sort_order = 4 WHERE name = 'B-L-T' AND category = 'Burgers';
UPDATE menu_items SET sort_order = 5 WHERE name = 'Firehouse Paradise' AND category = 'Burgers';
UPDATE menu_items SET sort_order = 6 WHERE name = 'Sliders Burger' AND category = 'Burgers';
UPDATE menu_items SET sort_order = 7 WHERE name = 'Double Decker' AND category = 'Burgers';

-- Update sort_order for existing Pizza items
-- Classic Flavor
UPDATE menu_items SET sort_order = 1 WHERE name = 'Supreme Cheese' AND category = 'Pizza';
UPDATE menu_items SET sort_order = 2 WHERE name = 'Bacon & Cheese' AND category = 'Pizza';
UPDATE menu_items SET sort_order = 3 WHERE name = 'Classic Aloha' AND category = 'Pizza';
UPDATE menu_items SET sort_order = 4 WHERE name = 'Vegan Lover' AND category = 'Pizza';
-- Supreme Flavor
UPDATE menu_items SET sort_order = 5 WHERE name = 'Ultimate Aloha' AND category = 'Pizza';
UPDATE menu_items SET sort_order = 6 WHERE name = 'Pepperoni & Bacon' AND category = 'Pizza';
UPDATE menu_items SET sort_order = 7 WHERE name = 'Tuna Jalapeno' AND category = 'Pizza';
UPDATE menu_items SET sort_order = 8 WHERE name = 'Gurus Choice' AND category = 'Pizza';
UPDATE menu_items SET sort_order = 9 WHERE name = 'Meat Overload' AND category = 'Pizza';
UPDATE menu_items SET sort_order = 10 WHERE name = 'Pick of the Bunch' AND category = 'Pizza';

-- Update sort_order for existing Wings items
UPDATE menu_items SET sort_order = 1 WHERE name = 'Plain Wings' AND category = 'Wings';
UPDATE menu_items SET sort_order = 2 WHERE name = 'Parmesan Wings' AND category = 'Wings';
UPDATE menu_items SET sort_order = 3 WHERE name = 'Korean Soy Wings' AND category = 'Wings';
UPDATE menu_items SET sort_order = 4 WHERE name = 'Buffalo Wings' AND category = 'Wings';
UPDATE menu_items SET sort_order = 5 WHERE name = 'Trio Wings' AND category = 'Wings';
UPDATE menu_items SET sort_order = 6 WHERE name = 'Medium Tray Wings' AND category = 'Wings';
UPDATE menu_items SET sort_order = 7 WHERE name = 'Large Tray Wings' AND category = 'Wings';

-- Update sort_order for existing Sandwiches items
UPDATE menu_items SET sort_order = 1 WHERE name = 'Clubhouse Sandwich' AND category = 'Sandwiches';
UPDATE menu_items SET sort_order = 2 WHERE name = 'Chicken Sandwich' AND category = 'Sandwiches';

-- Update sort_order for existing Pasta items
UPDATE menu_items SET sort_order = 1 WHERE name = 'Pinoy Spaghetti' AND category = 'Pasta';
UPDATE menu_items SET sort_order = 2 WHERE name = 'Carbonara' AND category = 'Pasta';
UPDATE menu_items SET sort_order = 3 WHERE name = 'Tuna Basil' AND category = 'Pasta';
UPDATE menu_items SET sort_order = 4 WHERE name = 'Baked Macaroni' AND category = 'Pasta';
UPDATE menu_items SET sort_order = 5 WHERE name = 'Vietnamese Pasta' AND category = 'Pasta';

-- Update sort_order for existing Solo Meals items
UPDATE menu_items SET sort_order = 1 WHERE name = 'GOURMET 1' AND category = 'Solo Meals';
UPDATE menu_items SET sort_order = 2 WHERE name = 'GOURMET 2' AND category = 'Solo Meals';
UPDATE menu_items SET sort_order = 3 WHERE name = 'GOURMET 3' AND category = 'Solo Meals';
UPDATE menu_items SET sort_order = 4 WHERE name = 'GOURMET 4' AND category = 'Solo Meals';
UPDATE menu_items SET sort_order = 5 WHERE name = 'GOURMET 5' AND category = 'Solo Meals';

-- Update sort_order for existing Batangas Lomi items
UPDATE menu_items SET sort_order = 1 WHERE name = 'Batangas Lomi' AND category = 'Batangas Lomi';

-- Update sort_order for existing Cold Beverages items
UPDATE menu_items SET sort_order = 1 WHERE name = 'Soda in Can' AND category = 'Cold Beverages';
UPDATE menu_items SET sort_order = 2 WHERE name = 'Soda 1.5L' AND category = 'Cold Beverages';
UPDATE menu_items SET sort_order = 3 WHERE name = 'Juice' AND category = 'Cold Beverages';
UPDATE menu_items SET sort_order = 4 WHERE name = 'Solo' AND category = 'Cold Beverages';
UPDATE menu_items SET sort_order = 5 WHERE name = 'Pitcher' AND category = 'Cold Beverages';
UPDATE menu_items SET sort_order = 6 WHERE name = 'Pineapple Juice' AND category = 'Cold Beverages';
UPDATE menu_items SET sort_order = 7 WHERE name = 'Bottled Water 500ml' AND category = 'Cold Beverages';

-- Update sort_order for existing Hot Beverages items
UPDATE menu_items SET sort_order = 1 WHERE name = 'Kapeng Barako' AND category = 'Hot Beverages';
UPDATE menu_items SET sort_order = 2 WHERE name = 'Honey Lemon Tea' AND category = 'Hot Beverages';

-- Update sort_order for existing Frappe items
UPDATE menu_items SET sort_order = 1 WHERE name = 'Java Chip Frappe' AND category = 'Frappe';
UPDATE menu_items SET sort_order = 2 WHERE name = 'Mocha Frappe' AND category = 'Frappe';
UPDATE menu_items SET sort_order = 3 WHERE name = 'Chocolate Frappe' AND category = 'Frappe';
UPDATE menu_items SET sort_order = 4 WHERE name = 'Cookies and Cream Frappe' AND category = 'Frappe';
UPDATE menu_items SET sort_order = 5 WHERE name = 'Caramel Macchiato Frappe' AND category = 'Frappe';

-- Update sort_order for existing Beer items
UPDATE menu_items SET sort_order = 1 WHERE name = 'San Mig Light in Can' AND category = 'Beer';
UPDATE menu_items SET sort_order = 2 WHERE name = 'Bucket Beer' AND category = 'Beer';

-- Update sort_order for existing Breakfast items
UPDATE menu_items SET sort_order = 1 WHERE name = 'Liempo Silog' AND category = 'Breakfast';
UPDATE menu_items SET sort_order = 2 WHERE name = 'Bangus Silog' AND category = 'Breakfast';
UPDATE menu_items SET sort_order = 3 WHERE name = 'Bacon Silog' AND category = 'Breakfast';
UPDATE menu_items SET sort_order = 4 WHERE name = 'Ham Silog' AND category = 'Breakfast';
UPDATE menu_items SET sort_order = 5 WHERE name = 'Tinapa Silog' AND category = 'Breakfast';
UPDATE menu_items SET sort_order = 6 WHERE name = 'Danggit Silog' AND category = 'Breakfast';

-- Update sort_order for existing Rice Meals items
-- Row 1 (Right to Left)
UPDATE menu_items SET sort_order = 1 WHERE name = 'Grilled Liempo' AND category = 'Rice Meals';
UPDATE menu_items SET sort_order = 2 WHERE name = 'Gourmet Chops' AND category = 'Rice Meals';
UPDATE menu_items SET sort_order = 3 WHERE name = 'Korean Soy or Buffalo' AND category = 'Rice Meals';
UPDATE menu_items SET sort_order = 4 WHERE name = 'Boneless Bangus' AND category = 'Rice Meals';
-- Row 2 (Right to Left)
UPDATE menu_items SET sort_order = 5 WHERE name = 'Chicken Poppers' AND category = 'Rice Meals';
UPDATE menu_items SET sort_order = 6 WHERE name = 'Fried Chicken' AND category = 'Rice Meals';
UPDATE menu_items SET sort_order = 7 WHERE name = 'Fish Fillet' AND category = 'Rice Meals';
UPDATE menu_items SET sort_order = 8 WHERE name = 'Grilled Chicken' AND category = 'Rice Meals';
-- Row 3 (Right to Left)
UPDATE menu_items SET sort_order = 9 WHERE name = 'Salisbury Steak' AND category = 'Rice Meals';
UPDATE menu_items SET sort_order = 10 WHERE name = 'Mushroom Steak' AND category = 'Rice Meals';
UPDATE menu_items SET sort_order = 11 WHERE name = 'Hungarian or Buffalo' AND category = 'Rice Meals';
UPDATE menu_items SET sort_order = 12 WHERE name = 'Chicken Fillet' AND category = 'Rice Meals';

-- Insert/Update categories (if categories table exists)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'categories') THEN
    -- Insert Firehouse Pizzeria categories
    INSERT INTO categories (id, name, icon, sort_order, active) VALUES
      ('starters', 'Starters', '🍽️', 1, true),
      ('salads', 'Salads', '🥗', 2, true),
      ('burgers', 'Burgers', '🍔', 3, true),
      ('pizza', 'Pizza', '🍕', 4, true),
      ('wings', 'Wings', '🍗', 5, true),
      ('sandwiches', 'Sandwiches', '🥪', 6, true),
      ('pasta', 'Pasta', '🍝', 7, true),
      ('solo-meals', 'Solo Meals', '🍚', 8, true),
      ('batangas-lomi', 'Batangas Lomi', '🍜', 9, true),
      ('cold-beverages', 'Cold Beverages', '🥤', 10, true),
      ('hot-beverages', 'Hot Beverages', '☕', 11, true),
      ('frappe', 'Frappe', '🧋', 12, true),
      ('beer', 'Beer', '🍺', 13, true),
      ('breakfast', 'Breakfast', '🍳', 14, true),
      ('rice-meals', 'Rice Meals', '🍛', 15, true)
    ON CONFLICT (id) DO UPDATE SET
      sort_order = EXCLUDED.sort_order,
      active = EXCLUDED.active;
  END IF;
END $$;

-- Create variations table
CREATE TABLE IF NOT EXISTS variations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  menu_item_id uuid REFERENCES menu_items(id) ON DELETE CASCADE,
  name text NOT NULL,
  price decimal(10,2) NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Create add_ons table
CREATE TABLE IF NOT EXISTS add_ons (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  menu_item_id uuid REFERENCES menu_items(id) ON DELETE CASCADE,
  name text NOT NULL,
  price decimal(10,2) NOT NULL DEFAULT 0,
  category text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE variations ENABLE ROW LEVEL SECURITY;
ALTER TABLE add_ons ENABLE ROW LEVEL SECURITY;

-- Create policies for public read access (only if they don't exist)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Anyone can read menu items' AND tablename = 'menu_items') THEN
    CREATE POLICY "Anyone can read menu items"
      ON menu_items
      FOR SELECT
      TO public
      USING (true);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Anyone can read variations' AND tablename = 'variations') THEN
    CREATE POLICY "Anyone can read variations"
      ON variations
      FOR SELECT
      TO public
      USING (true);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Anyone can read add-ons' AND tablename = 'add_ons') THEN
    CREATE POLICY "Anyone can read add-ons"
      ON add_ons
      FOR SELECT
      TO public
      USING (true);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Authenticated users can manage menu items' AND tablename = 'menu_items') THEN
    CREATE POLICY "Authenticated users can manage menu items"
      ON menu_items
      FOR ALL
      TO authenticated
      USING (true)
      WITH CHECK (true);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Authenticated users can manage variations' AND tablename = 'variations') THEN
    CREATE POLICY "Authenticated users can manage variations"
      ON variations
      FOR ALL
      TO authenticated
      USING (true)
      WITH CHECK (true);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Authenticated users can manage add-ons' AND tablename = 'add_ons') THEN
    CREATE POLICY "Authenticated users can manage add-ons"
      ON add_ons
      FOR ALL
      TO authenticated
      USING (true)
      WITH CHECK (true);
  END IF;
END $$;

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for menu_items (only if it doesn't exist)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_menu_items_updated_at') THEN
    CREATE TRIGGER update_menu_items_updated_at
      BEFORE UPDATE ON menu_items
      FOR EACH ROW
      EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

-- Update existing menu items or insert new ones (prevent duplicates)
-- Items without variations/add-ons
INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Cheesy Nachos', 'Crispy tortilla chips topped with melted cheese and served with salsa', 115.00, 'Starters', false, true, null, null, null, null, false, 1, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Cheesy Nachos');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Taco Bites', 'Mini tacos filled with seasoned meat and fresh vegetables', 80.00, 'Starters', false, true, null, null, null, null, false, 2, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Taco Bites');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Snack Platter', 'A combination of nachos, mojos, and fries - perfect for sharing', 325.00, 'Starters', false, true, null, null, null, null, false, 5, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Snack Platter');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Cheese Quesadilla', 'Warm tortilla filled with melted cheese and served with sour cream', 135.00, 'Starters', false, true, null, null, null, null, false, 6, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Cheese Quesadilla');

-- Update existing TORTIZZA items (remove NEW prefix)
UPDATE menu_items 
SET name = 'TORTIZZA', description = 'Our signature tortilla pizza with fresh toppings', base_price = 165.00, popular = false, updated_at = now()
WHERE name LIKE '%TORTIZZA%' OR name LIKE '%NEW TORTIZZA%';

-- Insert TORTIZZA if it doesn't exist
INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'TORTIZZA', 'Our signature tortilla pizza with fresh toppings', 165.00, 'Starters', false, true, null, null, null, null, false, 7, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'TORTIZZA');

-- Update existing Double Cheese Bread items (remove NEW prefix)
UPDATE menu_items 
SET name = 'Double Cheese Bread', description = 'Fresh bread loaded with double cheese and herbs', base_price = 145.00, popular = false, updated_at = now()
WHERE name LIKE '%Double Cheese Bread%' OR name LIKE '%NEW Double Cheese Bread%';

-- Insert Double Cheese Bread if it doesn't exist
INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Double Cheese Bread', 'Fresh bread loaded with double cheese and herbs', 145.00, 'Starters', false, true, null, null, null, null, false, 8, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Double Cheese Bread');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Onion Rings', 'Crispy golden onion rings served with dipping sauce', 180.00, 'Starters', false, true, null, null, null, null, false, 9, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Onion Rings');

-- Items with variations
INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'French Fries', 'Golden crispy french fries, perfectly seasoned', 75.00, 'Starters', false, true, null, null, null, null, false, 3, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'French Fries');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Mojitos', 'Refreshing mint mojito cocktail', 105.00, 'Starters', false, true, null, null, null, null, false, 4, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Mojitos');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Chicken n'' Fish Chips', 'Tender chicken and fish served with crispy chips', 225.00, 'Starters', false, true, null, null, null, null, false, 10, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Chicken n'' Fish Chips');

-- Add variations for French Fries (75/225)
INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Large',
  225.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'French Fries'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Large');

-- Add variations for Mojitos (105/315)
INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Large',
  315.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Mojitos'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Large');

-- Add variations for Chicken n' Fish Chips (Double: 225, Sharing: 365, Family: 699)
INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Sharing',
  365.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Chicken n'' Fish Chips'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Sharing');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Family',
  699.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Chicken n'' Fish Chips'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Family');

-- Remove all existing add-ons for starter items (they should be served as standard items)
DELETE FROM add_ons 
WHERE menu_item_id IN (
  SELECT id FROM menu_items 
  WHERE category = 'Starters'
);

-- Aggressively remove all duplicate starter items (keep only one of each)
-- Remove variations for duplicate starter items
DELETE FROM variations 
WHERE menu_item_id IN (
  SELECT id FROM menu_items 
  WHERE category = 'Starters' 
  AND id NOT IN (
    SELECT mi.id
    FROM menu_items mi
    INNER JOIN (
      SELECT name, MIN(created_at) as oldest_created_at
      FROM menu_items 
      WHERE category = 'Starters'
      GROUP BY name
    ) sd ON mi.name = sd.name AND mi.created_at = sd.oldest_created_at
  )
);

-- Remove add-ons for duplicate starter items
DELETE FROM add_ons 
WHERE menu_item_id IN (
  SELECT id FROM menu_items 
  WHERE category = 'Starters' 
  AND id NOT IN (
    SELECT mi.id
    FROM menu_items mi
    INNER JOIN (
      SELECT name, MIN(created_at) as oldest_created_at
      FROM menu_items 
      WHERE category = 'Starters'
      GROUP BY name
    ) sd ON mi.name = sd.name AND mi.created_at = sd.oldest_created_at
  )
);

-- Remove duplicate starter menu items
DELETE FROM menu_items 
WHERE category = 'Starters'
AND id NOT IN (
  SELECT mi.id
  FROM menu_items mi
  INNER JOIN (
    SELECT name, MIN(created_at) as oldest_created_at
    FROM menu_items 
    WHERE category = 'Starters'
    GROUP BY name
  ) sd ON mi.name = sd.name AND mi.created_at = sd.oldest_created_at
);

-- No add-ons for starter items - they are served as standard items

-- Add Salad Menu Items (prevent duplicates)
INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Green Tossed Salad', 'A fresh, vibrant dish made up of a variety of crisp, leafy greens, typically including romaine, iceberg lightly dressed with our creamy home based salad dressing topped with pineapple, onion, cucumber, tomato, black olives, carrots and croutons sprinkle with cheese on top', 150.00, 'Salads', false, true, null, null, null, null, false, 1, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Green Tossed Salad');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Firehouse Salad', 'Firehouse salad is a fresh, vibrant dish made up of a variety of crisp, leafy greens, typically including romaine, iceberg lightly dressed with our creamy home based salad dressing topped with pineapple, onion, cucumber, tomato, carrots and croutons sprinkle with cheese on top addition of Boiled egg and Sweet Ham', 180.00, 'Salads', false, true, null, null, null, null, false, 2, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Firehouse Salad');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Paradise Salad', 'A fresh bed of crisp romaine and ice berg with fresh vegetables such as cucumber, tomato, onion, korn kernel, pineapple, carrot topped with croutons and Chicken Chunks and Bacon Bits and raisins. Dressing: Roasted Sesame', 215.00, 'Salads', false, true, null, null, null, null, false, 3, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Paradise Salad');

-- Salad variations removed - salads will be simple without variations

-- Salad add-ons removed - salads will be simple without add-ons

-- Clean up any existing salad variations and add-ons (in case this migration is run on existing data)
DELETE FROM variations 
WHERE menu_item_id IN (
  SELECT id FROM menu_items 
  WHERE category = 'Salads'
);

DELETE FROM add_ons 
WHERE menu_item_id IN (
  SELECT id FROM menu_items 
  WHERE category = 'Salads'
);

-- Add Burger Menu Items (prevent duplicates)
INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Classic Burger', 'Juicy beef patty with fresh lettuce, tomato, and our signature sauce', 95.00, 'Burgers', false, true, null, null, null, null, false, 1, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Classic Burger');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Bacon & Mushroom', 'Delicious burger topped with crispy bacon and sautéed mushrooms', 170.00, 'Burgers', false, true, null, null, null, null, false, 2, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Bacon & Mushroom');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Jalapeno', 'Spicy burger with jalapeno peppers and pepper jack cheese', 180.00, 'Burgers', false, true, null, null, null, null, false, 3, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Jalapeno');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'B-L-T', 'Classic bacon, lettuce, and tomato burger with mayo', 180.00, 'Burgers', false, true, null, null, null, null, false, 4, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'B-L-T');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Firehouse Paradise', 'Our signature burger with all the best toppings', 195.00, 'Burgers', false, true, null, null, null, null, false, 5, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Firehouse Paradise');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Sliders Burger', 'Mini burger with fries - perfect for sharing', 245.00, 'Burgers', false, true, null, null, null, null, false, 6, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Sliders Burger');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Double Decker', 'Double beef patties with double cheese and special sauce', 295.00, 'Burgers', false, true, null, null, null, null, false, 7, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Double Decker');

-- Add Pizza Menu Items (with size variations)
-- Classic Flavor Pizzas
INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Supreme Cheese', 'Classic pizza loaded with mozzarella and cheddar cheese', 185.00, 'Pizza', false, true, null, null, null, null, false, 1, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Supreme Cheese');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Bacon & Cheese', 'Crispy bacon with melted cheese on our signature crust', 195.00, 'Pizza', false, true, null, null, null, null, false, 2, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Bacon & Cheese');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Classic Aloha', 'Hawaiian-style pizza with ham and pineapple', 205.00, 'Pizza', false, true, null, null, null, null, false, 3, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Classic Aloha');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Vegan Lover', 'Plant-based pizza with vegan cheese and fresh vegetables', 215.00, 'Pizza', false, true, null, null, null, null, false, 4, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Vegan Lover');

-- Add Pizza Size Variations (Small and Large)
INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Large',
  50.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Supreme Cheese'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Large');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Large',
  50.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Bacon & Cheese'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Large');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Large',
  50.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Classic Aloha'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Large');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Large',
  50.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Vegan Lover'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Large');

-- Add Supreme Flavor Pizza Menu Items (with size variations)
INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Ultimate Aloha', 'Premium Hawaiian pizza with premium ham and pineapple', 230.00, 'Pizza', false, true, null, null, null, null, false, 5, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Ultimate Aloha');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Pepperoni & Bacon', 'Classic pepperoni with crispy bacon on our signature crust', 275.00, 'Pizza', false, true, null, null, null, null, false, 6, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Pepperoni & Bacon');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Tuna Jalapeno', 'Fresh tuna with spicy jalapeno peppers and cheese', 325.00, 'Pizza', false, true, null, null, null, null, false, 7, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Tuna Jalapeno');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Gurus Choice', 'Our chef''s special selection of premium toppings', 325.00, 'Pizza', false, true, null, null, null, null, false, 8, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Gurus Choice');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Meat Overload', 'Loaded with all your favorite meats and cheese', 345.00, 'Pizza', false, true, null, null, null, null, false, 9, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Meat Overload');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Pick of the Bunch', 'A delightful mix of our best ingredients', 345.00, 'Pizza', false, true, null, null, null, null, false, 10, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Pick of the Bunch');

-- Add Supreme Flavor Pizza Size Variations
INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Large',
  80.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Ultimate Aloha'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Large');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Large',
  105.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Pepperoni & Bacon'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Large');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Large',
  95.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Tuna Jalapeno'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Large');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Large',
  95.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Gurus Choice'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Large');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Large',
  105.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Meat Overload'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Large');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Large',
  135.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Pick of the Bunch'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Large');

-- Add Wings Menu Items (prevent duplicates)
INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Plain Wings', 'Crispy chicken wings served plain', 250.00, 'Wings', false, true, null, null, null, null, false, 1, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Plain Wings');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Parmesan Wings', 'Chicken wings coated with parmesan cheese', 260.00, 'Wings', false, true, null, null, null, null, false, 2, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Parmesan Wings');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Korean Soy Wings', 'Asian-inspired wings with Korean soy glaze', 260.00, 'Wings', false, true, null, null, null, null, false, 3, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Korean Soy Wings');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Buffalo Wings', 'Classic spicy buffalo wings with ranch dip', 260.00, 'Wings', false, true, null, null, null, null, false, 4, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Buffalo Wings');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Trio Wings', 'Three different flavors of wings in one order', 750.00, 'Wings', false, true, null, null, null, null, false, 5, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Trio Wings');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Medium Tray Wings', 'Medium tray of assorted wings for sharing', 1250.00, 'Wings', false, true, null, null, null, null, false, 6, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Medium Tray Wings');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Large Tray Wings', 'Large tray of assorted wings for big groups', 2250.00, 'Wings', false, true, null, null, null, null, false, 7, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Large Tray Wings');

-- Add Sandwich Menu Items (prevent duplicates)
INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Clubhouse Sandwich', 'Classic clubhouse with turkey, bacon, lettuce, and tomato', 170.00, 'Sandwiches', false, true, null, null, null, null, false, 1, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Clubhouse Sandwich');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Chicken Sandwich', 'Grilled chicken breast with fresh vegetables and sauce', 150.00, 'Sandwiches', false, true, null, null, null, null, false, 2, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Chicken Sandwich');

-- Add Pasta Menu Items (with portion variations)
INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Pinoy Spaghetti', 'Filipino-style sweet spaghetti with hotdog and cheese', 75.00, 'Pasta', false, true, null, null, null, null, false, 1, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Pinoy Spaghetti');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Carbonara', 'Creamy pasta with bacon and parmesan cheese', 105.00, 'Pasta', false, true, null, null, null, null, false, 2, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Carbonara');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Tuna Basil', 'Fresh tuna with basil and olive oil pasta', 105.00, 'Pasta', false, true, null, null, null, null, false, 3, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Tuna Basil');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Baked Macaroni', 'Creamy macaroni topped with cheese and baked to perfection', 135.00, 'Pasta', false, true, null, null, null, null, false, 4, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Baked Macaroni');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Vietnamese Pasta', 'Vietnamese-inspired pasta with fresh herbs and spices', 150.00, 'Pasta', false, true, null, null, null, null, false, 5, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Vietnamese Pasta');

-- Add Pasta Portion Variations (Solo and Sharing)
INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Sharing',
  215.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Pinoy Spaghetti'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Sharing');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Sharing',
  265.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Carbonara'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Sharing');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Sharing',
  265.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Tuna Basil'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Sharing');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Sharing',
  245.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Baked Macaroni'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Sharing');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Sharing',
  400.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Vietnamese Pasta'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Sharing');

-- Add Solo Meals Menu Items (prevent duplicates)
INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'GOURMET 1', 'Pinoy Style Spaghetti, Ham & Egg Sandwich with fries and drinks. Upgrade +10 BURGER', 225.00, 'Solo Meals', false, true, null, null, null, null, false, 1, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'GOURMET 1');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'GOURMET 2', 'Pinoy Style Spaghetti, 2 slices Pizza with fries and drinks', 235.00, 'Solo Meals', false, true, null, null, null, null, false, 2, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'GOURMET 2');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'GOURMET 3', 'Pinoy Style Spaghetti, Chicken Sandwich with fries and drinks', 235.00, 'Solo Meals', false, true, null, null, null, null, false, 3, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'GOURMET 3');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'GOURMET 4', 'Cheesy Baked Mac, Classic Burger with drinks', 255.00, 'Solo Meals', false, true, null, null, null, null, false, 4, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'GOURMET 4');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'GOURMET 5', 'Pinoy Style Spaghetti, Plain Fried Chicken with fries and drinks', 245.00, 'Solo Meals', false, true, null, null, null, null, false, 5, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'GOURMET 5');

-- Add Batangas Lomi Menu Items (with size variations)
INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Batangas Lomi', 'Lomi noodles from Batangas are comfort food known for their rich, hearty broth and thick, chewy noodles', 130.00, 'Batangas Lomi', false, true, null, null, null, null, false, 1, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Batangas Lomi');

-- Add Batangas Lomi Size Variations (Solo and Jumbo)
INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Jumbo',
  160.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Batangas Lomi'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Jumbo');

-- Add Frappe Menu Items (prevent duplicates)
INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Java Chip Frappe', 'Rich coffee frappe with chocolate chips', 95.00, 'Frappe', false, true, null, null, null, null, false, 1, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Java Chip Frappe');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Mocha Frappe', 'Classic mocha frappe with chocolate and coffee', 95.00, 'Frappe', false, true, null, null, null, null, false, 2, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Mocha Frappe');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Chocolate Frappe', 'Rich chocolate frappe blended to perfection', 95.00, 'Frappe', false, true, null, null, null, null, false, 3, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Chocolate Frappe');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Cookies and Cream Frappe', 'Creamy frappe with cookies and cream flavor', 120.00, 'Frappe', false, true, null, null, null, null, false, 4, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Cookies and Cream Frappe');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Caramel Macchiato Frappe', 'Smooth frappe with caramel and macchiato flavors', 120.00, 'Frappe', false, true, null, null, null, null, false, 5, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Caramel Macchiato Frappe');

-- Add Cold Beverages Menu Items (with flavor variations)
INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Soda in Can', 'Refreshing soda in can', 55.00, 'Cold Beverages', false, true, null, null, null, null, false, 1, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Soda in Can');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Soda 1.5L', 'Large bottle of refreshing soda', 95.00, 'Cold Beverages', false, true, null, null, null, null, false, 2, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Soda 1.5L');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Juice', 'Fresh fruit juice', 55.00, 'Cold Beverages', false, true, null, null, null, null, false, 3, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Juice');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Solo', 'Refreshing solo drink', 55.00, 'Cold Beverages', false, true, null, null, null, null, false, 4, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Solo');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Pitcher', 'Large pitcher of refreshing drink', 165.00, 'Cold Beverages', false, true, null, null, null, null, false, 5, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Pitcher');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Pineapple Juice', 'Fresh pineapple juice', 55.00, 'Cold Beverages', false, true, null, null, null, null, false, 6, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Pineapple Juice');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Bottled Water 500ml', 'Pure bottled water', 25.00, 'Cold Beverages', false, true, null, null, null, null, false, 7, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Bottled Water 500ml');

-- Add Cold Beverages Flavor Variations
-- Soda in Can variations (coke, sprite, royal)
INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Coke',
  0.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Soda in Can'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Coke');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Sprite',
  0.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Soda in Can'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Sprite');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Royal',
  0.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Soda in Can'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Royal');

-- Soda 1.5L variations (coke, sprite, royal)
INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Coke',
  0.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Soda 1.5L'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Coke');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Sprite',
  0.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Soda 1.5L'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Sprite');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Royal',
  0.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Soda 1.5L'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Royal');

-- Juice variations (cucumber, houseblend, blue lemonade, citrus dew)
INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Cucumber',
  0.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Juice'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Cucumber');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Houseblend',
  0.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Juice'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Houseblend');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Blue Lemonade',
  0.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Juice'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Blue Lemonade');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Citrus Dew',
  0.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Juice'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Citrus Dew');

-- Add Hot Beverages Menu Items (prevent duplicates)
INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Kapeng Barako', 'Strong Filipino coffee from Batangas', 85.00, 'Hot Beverages', false, true, null, null, null, null, false, 1, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Kapeng Barako');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Honey Lemon Tea', 'Warm and soothing honey lemon tea', 120.00, 'Hot Beverages', false, true, null, null, null, null, false, 2, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Honey Lemon Tea');

-- Add Beer Menu Items (prevent duplicates)
INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'San Mig Light in Can', 'Light beer in can', 75.00, 'Beer', false, true, null, null, null, null, false, 1, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'San Mig Light in Can');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Bucket Beer', 'Large bucket of beer for sharing', 430.00, 'Beer', false, true, null, null, null, null, false, 2, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Bucket Beer');

-- Add Breakfast Menu Items (prevent duplicates)
INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Liempo Silog', 'Grilled pork belly with garlic rice and egg', 180.00, 'Breakfast', false, true, null, null, null, null, false, 1, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Liempo Silog');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Bangus Silog', 'Grilled milkfish with garlic rice and egg', 165.00, 'Breakfast', false, true, null, null, null, null, false, 2, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Bangus Silog');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Bacon Silog', 'Crispy bacon with garlic rice and egg', 155.00, 'Breakfast', false, true, null, null, null, null, false, 3, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Bacon Silog');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Ham Silog', 'Sliced ham with garlic rice and egg', 155.00, 'Breakfast', false, true, null, null, null, null, false, 4, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Ham Silog');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Tinapa Silog', 'Smoked fish with garlic rice and egg', 115.00, 'Breakfast', false, true, null, null, null, null, false, 5, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Tinapa Silog');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Danggit Silog', 'Dried fish with garlic rice and egg', 165.00, 'Breakfast', false, true, null, null, null, null, false, 6, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Danggit Silog');

-- Add Rice Meals Menu Items (with some variations)
-- Row 1 (Right to Left): Grilled Liempo, Gourmet Chops, Korean Soy or Buffalo, Boneless Bangus
INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Grilled Liempo', 'Grilled pork belly with rice. UPGRADE +P35 UNLI RICE. FREE 12OZ DRINK', 180.00, 'Rice Meals', false, true, null, null, null, null, false, 1, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Grilled Liempo');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Gourmet Chops', 'Premium pork chops with rice. UPGRADE +P35 UNLI RICE. FREE 12OZ DRINK', 180.00, 'Rice Meals', false, true, null, null, null, null, false, 2, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Gourmet Chops');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Korean Soy or Buffalo', 'Korean soy or buffalo flavored dish with rice. UPGRADE +P35 UNLI RICE. FREE 12OZ DRINK', 155.00, 'Rice Meals', false, true, null, null, null, null, false, 3, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Korean Soy or Buffalo');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Boneless Bangus', 'Boneless milkfish with rice. UPGRADE +P35 UNLI RICE. FREE 12OZ DRINK', 165.00, 'Rice Meals', false, true, null, null, null, null, false, 4, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Boneless Bangus');

-- Row 2 (Right to Left): Chicken Poppers, Fried Chicken, Fish Fillet, Grilled Chicken
INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Chicken Poppers', 'Crispy chicken poppers with rice. UPGRADE +P35 UNLI RICE. FREE 12OZ DRINK', 129.00, 'Rice Meals', false, true, null, null, null, null, false, 5, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Chicken Poppers');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Fried Chicken', 'Crispy fried chicken with rice. UPGRADE +P35 UNLI RICE. FREE 12OZ DRINK', 150.00, 'Rice Meals', false, true, null, null, null, null, false, 6, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Fried Chicken');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Fish Fillet', 'Breaded fish fillet with rice. UPGRADE +P35 UNLI RICE. FREE 12OZ DRINK', 155.00, 'Rice Meals', false, true, null, null, null, null, false, 7, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Fish Fillet');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Grilled Chicken', 'Grilled chicken breast with rice. UPGRADE +P35 UNLI RICE. FREE 12OZ DRINK', 145.00, 'Rice Meals', false, true, null, null, null, null, false, 8, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Grilled Chicken');

-- Row 3 (Right to Left): Salisbury Steak, Mushroom Steak, Hungarian or Buffalo, Chicken Fillet
INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Salisbury Steak', 'Beef salisbury steak with rice. UPGRADE +P35 UNLI RICE. FREE 12OZ DRINK', 150.00, 'Rice Meals', false, true, null, null, null, null, false, 9, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Salisbury Steak');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Mushroom Steak', 'Mushroom steak with rice. UPGRADE +P35 UNLI RICE. FREE 12OZ DRINK', 150.00, 'Rice Meals', false, true, null, null, null, null, false, 10, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Mushroom Steak');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Hungarian or Buffalo', 'Hungarian or buffalo flavored dish with rice. UPGRADE +P35 UNLI RICE. FREE 12OZ DRINK', 160.00, 'Rice Meals', false, true, null, null, null, null, false, 11, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Hungarian or Buffalo');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, sort_order, created_at, updated_at)
SELECT gen_random_uuid(), 'Chicken Fillet', 'Breaded chicken fillet with rice. UPGRADE +P35 UNLI RICE. FREE 12OZ DRINK', 155.00, 'Rice Meals', false, true, null, null, null, null, false, 12, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Chicken Fillet');

-- Add Rice Meals Variations
-- Chicken Poppers has two prices (129/139)
INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Large',
  10.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Chicken Poppers'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Large');

-- Hungarian or Buffalo has two prices (160/180)
INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Large',
  20.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Hungarian or Buffalo'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Large');

-- Add upgrade variations for unlimited rice (+35)
INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Unlimited Rice',
  35.00,
  now()
FROM menu_items mi 
WHERE mi.category = 'Rice Meals'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Unlimited Rice');

-- Remove all popular flags - admin will control which items are popular
UPDATE menu_items 
SET popular = false
WHERE popular = true;

-- Update existing Group Meals to remove discount logic
UPDATE menu_items 
SET discount_active = false, discount_price = null, discount_start_date = null, discount_end_date = null
WHERE category = 'Group Meals';

-- Add Group Meals Menu Items (using original base prices, no discounts)
INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, created_at, updated_at)
SELECT gen_random_uuid(), 'Group Meals Set 1', 'Good for 3 pax: Spaghetti Platter, Sliders Burger with Fries, 10" Pizza Classic Aloha, Drinks 1.5L', 799.00, 'Group Meals', false, true, null, null, null, null, false, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Group Meals Set 1');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, created_at, updated_at)
SELECT gen_random_uuid(), 'Group Meals Set 2', 'Good for 4-6 pax: Baked Mac Platter, 12" Pizza Pepperoni & Bacon, 2 set of Clubhouse sandwich with fries, Cheesy Nachos, Drinks 1.5L', 1250.00, 'Group Meals', false, true, null, null, null, null, false, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Group Meals Set 2');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, created_at, updated_at)
SELECT gen_random_uuid(), 'Group Meals Set 3', 'Good for 6-8 pax: 2 sets of size 10" pizza (PickoftheBunch or MeatOverload and Tuna Jalapeno or Gurus Choice), Snack Platter, 2 Wings Platter, Drinks 1.5L, Spaghetti Platter, 1 Choice of pasta (bakedmac/tunabasil/carbonara)', 2150.00, 'Group Meals', false, true, null, null, null, null, false, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Group Meals Set 3');

INSERT INTO menu_items (id, name, description, base_price, category, popular, available, image_url, discount_price, discount_start_date, discount_end_date, discount_active, created_at, updated_at)
SELECT gen_random_uuid(), 'Group Meals Set 4', 'Good for 6-10 pax: 3 sets of size 10" pizza (Gurus Choice or Tuna Jalapeno, Meat Overload or Pick of the Bunch, Pepperoni & Bacon), 2 Onion Rings or Snack Platter, 2 Drinks 1.5L, Chicken Poppers family size, 2 Spaghetti Platter, 1 Choice of pasta (bakedmac/tunabasil/carbonara)', 2999.00, 'Group Meals', false, true, null, null, null, null, false, now(), now()
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = 'Group Meals Set 4');

-- Add Group Meals Variations for pizza choices
-- Set 3 Pizza variations
INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Pick of the Bunch',
  0.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Group Meals Set 3'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Pick of the Bunch');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Meat Overload',
  0.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Group Meals Set 3'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Meat Overload');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Tuna Jalapeno',
  0.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Group Meals Set 3'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Tuna Jalapeno');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Gurus Choice',
  0.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Group Meals Set 3'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Gurus Choice');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Baked Mac',
  0.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Group Meals Set 3'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Baked Mac');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Tuna Basil',
  0.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Group Meals Set 3'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Tuna Basil');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Carbonara',
  0.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Group Meals Set 3'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Carbonara');

-- Set 4 Pizza variations
INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Gurus Choice',
  0.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Group Meals Set 4'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Gurus Choice');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Tuna Jalapeno',
  0.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Group Meals Set 4'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Tuna Jalapeno');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Meat Overload',
  0.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Group Meals Set 4'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Meat Overload');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Pick of the Bunch',
  0.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Group Meals Set 4'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Pick of the Bunch');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Pepperoni & Bacon',
  0.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Group Meals Set 4'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Pepperoni & Bacon');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Onion Rings',
  0.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Group Meals Set 4'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Onion Rings');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Snack Platter',
  0.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Group Meals Set 4'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Snack Platter');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Baked Mac',
  0.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Group Meals Set 4'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Baked Mac');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Tuna Basil',
  0.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Group Meals Set 4'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Tuna Basil');

INSERT INTO variations (id, menu_item_id, name, price, created_at)
SELECT 
  gen_random_uuid(),
  mi.id,
  'Carbonara',
  0.00,
  now()
FROM menu_items mi 
WHERE mi.name = 'Group Meals Set 4'
AND NOT EXISTS (SELECT 1 FROM variations v WHERE v.menu_item_id = mi.id AND v.name = 'Carbonara');

-- Create storage bucket for menu images
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'menu-images',
  'menu-images',
  true,
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO NOTHING;

-- Create policy to allow public read access to menu images
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'storage' 
    AND tablename = 'objects' 
    AND policyname = 'Public read access for menu images'
  ) THEN
    CREATE POLICY "Public read access for menu images" ON storage.objects
      FOR SELECT USING (bucket_id = 'menu-images');
  END IF;
END $$;

-- Create policy to allow authenticated users to upload menu images
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'storage' 
    AND tablename = 'objects' 
    AND policyname = 'Authenticated users can upload menu images'
  ) THEN
    CREATE POLICY "Authenticated users can upload menu images" ON storage.objects
      FOR INSERT WITH CHECK (bucket_id = 'menu-images');
  END IF;
END $$;

-- Create policy to allow authenticated users to update menu images
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'storage' 
    AND tablename = 'objects' 
    AND policyname = 'Authenticated users can update menu images'
  ) THEN
    CREATE POLICY "Authenticated users can update menu images" ON storage.objects
      FOR UPDATE USING (bucket_id = 'menu-images');
  END IF;
END $$;

-- Create policy to allow authenticated users to delete menu images
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'storage' 
    AND tablename = 'objects' 
    AND policyname = 'Authenticated users can delete menu images'
  ) THEN
    CREATE POLICY "Authenticated users can delete menu images" ON storage.objects
      FOR DELETE USING (bucket_id = 'menu-images');
  END IF;
END $$;

-- Remove any existing foreign key constraint on menu_items.category
-- This constraint was causing issues because it expected category to reference categories.id
-- but we use category names as text values
DO $$
BEGIN
  -- Check if the constraint exists and drop it
  IF EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'menu_items_category_fkey'
    AND table_name = 'menu_items'
  ) THEN
    ALTER TABLE menu_items DROP CONSTRAINT menu_items_category_fkey;
  END IF;
END $$;

-- Create payment_methods table
CREATE TABLE IF NOT EXISTS payment_methods (
  id text PRIMARY KEY,
  name text NOT NULL,
  account_number text NOT NULL,
  account_name text NOT NULL,
  qr_code_url text NOT NULL,
  active boolean DEFAULT true,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create updated_at trigger for payment_methods (only if it doesn't exist)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_payment_methods_updated_at') THEN
    CREATE TRIGGER update_payment_methods_updated_at
      BEFORE UPDATE ON payment_methods
      FOR EACH ROW
      EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

-- Clear any existing payment methods - admin will add payment methods via dashboard
DELETE FROM payment_methods;

-- Disable RLS on payment_methods table for admin operations
-- This allows the admin dashboard to add/edit payment methods without authentication
ALTER TABLE payment_methods DISABLE ROW LEVEL SECURITY;
