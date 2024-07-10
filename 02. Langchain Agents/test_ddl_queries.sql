DROP TABLE IF EXISTS OrderToppings;
DROP TABLE IF EXISTS Feedback;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS Toppings;

-- Create Tables

CREATE TABLE Customer (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE Toppings (
    topping_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    base_preparation_time INT NOT NULL
);

CREATE TABLE Orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    preparation_time INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

CREATE TABLE OrderToppings (
    order_id INT NOT NULL,
    topping_id INT NOT NULL,
    PRIMARY KEY (order_id, topping_id),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (topping_id) REFERENCES Toppings(topping_id)
);

CREATE TABLE Feedback (
    feedback_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    feedback_text TEXT,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- Insert Sample Data

-- Insert Customers
INSERT INTO Customer (name) VALUES 
('John Doe'), ('Jane Smith'), ('Alice Johnson'), ('Bob Brown'), ('Charlie Davis'),
('Diana Evans'), ('Frank Green'), ('Grace Harris'), ('Hank Ingram'), ('Ivy Johnson'),
('Jack King'), ('Kara Lewis'), ('Liam Miller'), ('Mia Nelson'), ('Noah Owen');

-- Insert Toppings with Base Preparation Time
INSERT INTO Toppings (name, base_preparation_time) VALUES 
('Pepperoni', 5), 
('Mushrooms', 3), 
('Onions', 2), 
('Sausage', 7), 
('Bacon', 6);

-- Insert Orders, OrderToppings, and Feedback with Correlation
DO $$
DECLARE
    new_order_id INT;
    top_id INT;
    total_base_time INT;
    actual_prep_time INT;
    feedback_rating INT;
    feedback_text TEXT;
BEGIN
    FOR i IN 1..100 LOOP
        -- Insert an order with a random customer
        INSERT INTO Orders (customer_id, preparation_time)
        VALUES ((SELECT customer_id FROM Customer ORDER BY RANDOM() LIMIT 1), 0)
        RETURNING order_id INTO new_order_id;
        
        -- Randomly assign 1 to 3 toppings to each order and calculate total base time
        total_base_time := 0;
        FOR top_id IN (SELECT t1.topping_id FROM Toppings t1 ORDER BY RANDOM() LIMIT 3) LOOP
            INSERT INTO OrderToppings (order_id, topping_id)
            VALUES (new_order_id, top_id);
            
            total_base_time := total_base_time + (SELECT t2.base_preparation_time FROM Toppings t2 WHERE t2.topping_id = top_id);
        END LOOP;

        -- Adjust actual preparation time with a small random variation
        actual_prep_time := total_base_time + FLOOR(RANDOM() * 5 - 2);
        IF actual_prep_time < 1 THEN
            actual_prep_time := 1;  -- Ensure minimum preparation time of 1 minute
        END IF;

        -- Update the preparation time in the order
        UPDATE Orders SET preparation_time = actual_prep_time WHERE order_id = new_order_id;

        -- Generate feedback rating based on the correlation
        IF actual_prep_time < total_base_time - 3 THEN
            feedback_rating := 1;
            feedback_text := 'Pizza was undercooked and rushed.';
        ELSIF actual_prep_time < total_base_time - 1 THEN
            feedback_rating := 2;
            feedback_text := 'Pizza was slightly undercooked.';
        ELSIF actual_prep_time <= total_base_time + 1 THEN
            feedback_rating := 3;
            feedback_text := 'Pizza was average.';
        ELSIF actual_prep_time <= total_base_time + 3 THEN
            feedback_rating := 4;
            feedback_text := 'Pizza was good.';
        ELSE
            feedback_rating := 5;
            feedback_text := 'Pizza was perfectly cooked!';
        END IF;

        -- Insert feedback
        INSERT INTO Feedback (order_id, feedback_text, rating)
        VALUES (new_order_id, feedback_text, feedback_rating);
    END LOOP;
END $$;

SELECT * FROM Feedback;