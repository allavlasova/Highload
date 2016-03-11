-module (hw_response).
-define (SERVERNAME, "hw").
-export ([response405/0, response200/2, response403/0, response404/0]).

response405()->
	Response = "HTTP/1.1 405 Method Not Allowed\r\n" 
	++ "Server: " ++ "hw\r\n" 
	++ "Connection: close\r\n\r\n",
	Response.
%переделать типы
response200(Size, Type)->
	Response = "HTTP/1.1 200 OK\r\n" 
	++ "Server: " ++ "hw\r\n" 
	++ "Connection: close\r\n"
	++ "Date: " ++ httpd_util:rfc1123_date() ++ "\r\n"
	++ "Content-Length: " ++ integer_to_list(Size) ++ "\r\n"
	++ "Content-Type: " ++ Type ++ "\r\n\r\n",
	Response.

response403()->
	Response = "HTTP/1.1 403 Forbidden\r\n" 
	++ "Server: " ++ "hw\r\n" 
	++ "Connection: close\r\n"
	++ "Date: " ++ httpd_util:rfc1123_date() ++ "\r\n\r\n",
	Response.

response404()->
	Response = "HTTP/1.1 404 Not found\r\n" 
	++ "Server: " ++ "hw\r\n" 
	++ "Connection: close\r\n"
	++ "Date: " ++ httpd_util:rfc1123_date() ++ "\r\n\r\n",
	Response.