/*
  # Initial Schema Setup for Karunia Jaya Medika

  1. New Tables
    - products
      - id (uuid, primary key)
      - name (text)
      - description (text)
      - price (numeric)
      - stock (integer)
      - type (text) - 'service' or 'product'
      - created_at (timestamp)
      
    - shifts
      - id (uuid, primary key)
      - user_id (uuid, foreign key)
      - start_time (timestamp)
      - end_time (timestamp)
      - cash_start (numeric)
      - cash_end (numeric)
      - notes (text)
      - status (text) - 'active' or 'closed'
      
    - sales
      - id (uuid, primary key)
      - shift_id (uuid, foreign key)
      - total_amount (numeric)
      - payment_method (text)
      - created_at (timestamp)
      
    - sale_items
      - id (uuid, primary key)
      - sale_id (uuid, foreign key)
      - product_id (uuid, foreign key)
      - quantity (integer)
      - price (numeric)
      
  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users
*/

-- Products table
CREATE TABLE products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  price numeric NOT NULL DEFAULT 0,
  stock integer NOT NULL DEFAULT 0,
  type text NOT NULL CHECK (type IN ('service', 'product')),
  created_at timestamptz DEFAULT now()
);

-- Shifts table
CREATE TABLE shifts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users NOT NULL,
  start_time timestamptz NOT NULL DEFAULT now(),
  end_time timestamptz,
  cash_start numeric NOT NULL DEFAULT 0,
  cash_end numeric,
  notes text,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'closed')),
  created_at timestamptz DEFAULT now()
);

-- Sales table
CREATE TABLE sales (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  shift_id uuid REFERENCES shifts NOT NULL,
  total_amount numeric NOT NULL DEFAULT 0,
  payment_method text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Sale items table
CREATE TABLE sale_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_id uuid REFERENCES sales NOT NULL,
  product_id uuid REFERENCES products NOT NULL,
  quantity integer NOT NULL DEFAULT 1,
  price numeric NOT NULL DEFAULT 0
);

-- Enable RLS
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE shifts ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_items ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Authenticated users can read products"
  ON products FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert products"
  ON products FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update products"
  ON products FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Users can read their own shifts"
  ON shifts FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own shifts"
  ON shifts FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own shifts"
  ON shifts FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can read sales from their shifts"
  ON sales FOR SELECT
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM shifts
    WHERE shifts.id = sales.shift_id
    AND shifts.user_id = auth.uid()
  ));

CREATE POLICY "Users can create sales in their active shift"
  ON sales FOR INSERT
  TO authenticated
  WITH CHECK (EXISTS (
    SELECT 1 FROM shifts
    WHERE shifts.id = shift_id
    AND shifts.user_id = auth.uid()
    AND shifts.status = 'active'
  ));

CREATE POLICY "Users can read sale items from their sales"
  ON sale_items FOR SELECT
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM sales
    JOIN shifts ON shifts.id = sales.shift_id
    WHERE sales.id = sale_items.sale_id
    AND shifts.user_id = auth.uid()
  ));

CREATE POLICY "Users can create sale items in their active shift"
  ON sale_items FOR INSERT
  TO authenticated
  WITH CHECK (EXISTS (
    SELECT 1 FROM sales
    JOIN shifts ON shifts.id = sales.shift_id
    WHERE sales.id = sale_id
    AND shifts.user_id = auth.uid()
    AND shifts.status = 'active'
  ));