-- This code assumes the name of the database is 'dev'. If your databse has a different nme, update the code below.

CREATE SCHEMA trading_data;

CREATE TABLE dev.trading_data.trade_history(
trans_id varchar,
ticker varchar,
price decimal(8,2),
quantity bigint,
trans_type varchar,
trans_date date);


INSERT into dev.trading_data.trade_history values 
('154644', 'AMZN', '1876.02', '190', 'P', '2020-01-02'),
('154699', 'AMZN', '1877.98', '268', 'P', '2020-01-02'),
('156655', 'AMZN', '1870.00', '100', 'P', '2020-01-02'),
('156656', 'AMZN', '1876.02', '100', 'P', '2020-01-02'),
('156849', 'AMZN', '1865.65', '187', 'P', '2020-01-02'),
('166894', 'AMZN', '1897.67', '100', 'P', '2020-01-02'),
('166905', 'AMZN', '1897.89', '200', 'S', '2020-01-02');

COMMENT on table
dev.trading_data.trade_history is 'Table contains a list of all buy and sell transactions across the organization';
COMMENT on column
dev.trading_data.trade_history.trans_id is 'Unique transaction ID';
 COMMENT on column
dev.trading_data.trade_history.ticker is 'Stock ticker';
 COMMENT on column
dev.trading_data.trade_history.price is 'Purchase or sale price';
COMMENT on column
dev.trading_data.trade_history.quantity is 'Purchase or sale quantity';
COMMENT on column
dev.trading_data.trade_history.trans_type is 'Transaction type (P=purchase, S=sale)';
COMMENT on column
dev.trading_data.trade_history.trans_date is 'Purchase or sale date';