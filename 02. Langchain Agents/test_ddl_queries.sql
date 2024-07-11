-- Run the following commands and SQL queries to create the database and tables for the Pizza Shop dataset.
-- docker run --name pgvector-container -e POSTGRES_USER=langchain -e POSTGRES_PASSWORD=langchain -e POSTGRES_DB=langchain -p 6024:5432 -d pgvector/pgvector:pg16

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

ALTER TABLE feedback
    DROP COLUMN rating;

UPDATE feedback
SET feedback_text = 'My visit to the shop was fairly average. The restaurant had a straightforward, no-frills setup, which was fine, but it didn’t create much of an inviting atmosphere. The menu was quite extensive, which was nice, and I decided to try their Veggie pizza. The crust was alright, with a decent texture, but the toppings were somewhat underwhelming. The vegetables were fresh, but the overall flavor profile was lacking – it could have used a bit more seasoning or a more robust sauce. The service was satisfactory but not exceptional. The staff was polite but not particularly attentive, and I had to wait longer than expected for my order to be taken and for the pizza to arrive. When it did, it was lukewarm, which affected the overall enjoyment of the meal. The cleanliness of the place was decent, though there were a few minor areas that could have been tidied up more promptly. The prices were fair, aligning with the quality of the food and service. All in all, the shop offers a passable dining experience, but it didn’t leave a lasting impression. It’s an okay option if you’re in the area, but there’s definitely room for improvement in both food quality and service.'
WHERE feedback_id = 1;

UPDATE feedback
SET feedback_text = 'I recently visited the shop and had an overall decent experience. The ambiance was casual and relaxed, which was nice, but nothing particularly stood out. The menu had a good variety of pizzas to choose from, catering to different preferences. I decided to go with a classic Pepperoni pizza. The crust was good, with a nice balance between crispy and chewy, but the sauce was somewhat bland and lacked the rich, tangy flavor I was hoping for. The pepperoni was tasty but not particularly memorable. The service was adequate; the staff was friendly but seemed a bit distracted at times, which led to longer wait times than expected, even though the place wasn''t very crowded. The pizza arrived at our table warm, not piping hot, which was a bit disappointing. Cleanliness was average; the dining area was mostly clean, but I did notice a few tables that hadn''t been cleared promptly. The prices were reasonable, reflecting the quality of the food and service. While the shop didn’t wow me, it wasn’t a bad experience either. It''s a decent spot for a quick meal, but there’s room for improvement in terms of flavor and service efficiency.'
WHERE feedback_id = 2;

UPDATE feedback
SET feedback_text = 'My experience at the shop was absolutely delightful from start to finish. As soon as I entered, I was greeted with a warm welcome and a pleasant, aromatic ambiance. The decor was charming and set the perfect tone for a cozy dining experience. The menu was extensive, offering a variety of creative pizza options as well as classic favorites. I decided to try the Pepperoni and Mushroom pizza, and it was a fantastic choice. The crust was perfectly baked, with a nice chewy texture, and the toppings were generously portioned and incredibly fresh.The flavor combination was outstanding, with the pepperoni providing a slight spice and the mushrooms adding a rich, earthy depth. What truly impressed me was the attention to detail; each slice was crafted with care, and the balance of flavors was impeccable. The staff was courteous and knowledgeable, providing excellent recommendations and ensuring that our dining experience was smooth and enjoyable. The overall cleanliness and organization of the shop were commendable, making the environment feel safe and welcoming. The pricing was also reasonable, given the high quality of the food and service. the shop has certainly earned a loyal customer in me, and I highly recommend it to anyone looking for a top-notch pizza experience.'
WHERE feedback_id = 3;

UPDATE feedback
SET feedback_text = 'My visit to the shop was one of the worst dining experiences I''ve had. The first thing I noticed was the off-putting smell as I walked in, which was a mix of stale air and unclean surfaces. The tables were sticky and the floor was littered with crumbs and trash. I decided to give it a chance and ordered a Margherita pizza, but it was a huge mistake. The crust was burnt on the edges and soggy in the middle, making it nearly inedible. The tomato sauce was bland and tasted like it came straight from a can, and the cheese was sparse and rubbery. The service was abysmal. The staff appeared to be more interested in chatting among themselves than attending to customers. I had to wait for an extended period before anyone acknowledged my presence, and even then, they were unfriendly and dismissive. When my pizza finally arrived, it was cold, and there was no apology or explanation for the delay. The overall ambiance was terrible, with loud, unpleasant music and a generally chaotic environment. The prices were outrageously high considering the subpar quality of both the food and service. I left feeling frustrated and completely unsatisfied. the shop needs serious improvements before I would consider returning or recommending it to anyone.'
WHERE feedback_id = 10;

UPDATE feedback
SET feedback_text = 'My experience at the shop was extremely disappointing from start to finish. Upon entering, I was struck by the uncleanliness of the restaurant. The floors were dirty, and several tables had not been cleared or wiped down. The menu looked promising, but that was where the positives ended. I ordered a Pepperoni pizza, expecting a classic, flavorful meal. What I received was far from that. The crust was undercooked and doughy, and the tomato sauce was watery and tasteless. The pepperoni slices were sparse and overly greasy, making the entire pizza unappetizing. The service was equally poor. The staff seemed uninterested and disengaged, providing minimal assistance and showing a lack of basic customer service skills. I had to wait an unusually long time for my order despite the restaurant not being busy. When the pizza finally arrived, it was lukewarm at best. To make matters worse, the overall atmosphere was uninviting, with poor lighting and a lack of any real decor or charm. The pricing was surprisingly high for such low-quality food and service. I left feeling extremely dissatisfied and regretted choosing the shop. I would not recommend this place to anyone and won’t be returning.'
WHERE feedback_id = 11;

UPDATE feedback
SET feedback_text = 'I recently visited the shop and was thoroughly impressed with the entire experience. From the moment I walked in, the ambiance was inviting and the staff was incredibly friendly. The menu offered a diverse selection of pizzas, catering to various tastes and dietary preferences, which was a pleasant surprise. I opted for the Margherita pizza and it was nothing short of spectacular. The crust was perfectly thin and crispy, the tomato sauce was rich and flavorful, and the fresh basil added a delightful aroma. The mozzarella cheese melted beautifully, creating a perfect balance of flavors in every bite.What stood out to me was the quality of the ingredients; it was evident that the team prioritizes freshness and authenticity. The service was prompt and attentive, ensuring that our needs were met without being intrusive. Additionally, the shop maintained a high level of cleanliness, which added to the overall positive experience.I also appreciated the cozy seating arrangement, which made the dining experience more comfortable and enjoyable. Whether you’re a pizza aficionado or just looking for a great place to dine, the shop is definitely worth a visit. I will undoubtedly return to try more of their delicious offerings.'
WHERE feedback_id = 18;
