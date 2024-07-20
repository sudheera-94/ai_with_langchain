-- Getting Started
CREATE EXTENSION vector;

CREATE TABLE items (id bigserial PRIMARY KEY, embedding vector(3));

INSERT INTO items (embedding) VALUES ('[1,2,3]'), ('[4,5,6]');

-- Get the nearest neighbors by L2 distance
SELECT * FROM items ORDER BY embedding <-> '[3,1,2]' LIMIT 5;
-- Also supports inner product (<#>), cosine distance (<=>), and L1 distance (<+>, added in 0.7.0)
-- Note: <#> returns the negative inner product since Postgres only supports ASC order index scans on operators

