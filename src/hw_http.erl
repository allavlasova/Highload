-module (hw_http).
-define(DOCUMENT_ROOT, "priv").
-define(FILE_INDEX, "index.html").
-export ([start/2, accept/2, keepalive_loop/1]).

start(Server, ListenSocket) ->
    proc_lib:spawn(?MODULE, accept, [Server, ListenSocket]).

accept(Server, ListenSocket) ->
    case catch hw_server:accept(ListenSocket, Server) of
        {ok, Socket} ->
            keepalive_loop(Socket),
            {ok, Socket};
        {error, Reason} ->
            exit({error, Reason})
    end.

keepalive_loop(Socket) ->
    case handle_request(Socket) of
        keep_alive ->
            keepalive_loop(Socket);
        close ->
            gen_tcp:close(Socket),
            ok
    end.

handle_request(Socket) ->
    {ok, {http_request, Method, Path, _Version}} = gen_tcp:recv(Socket, 0),
    case (Method) of
       'GET' ->
            %io:format('Get'),
            get_response(Socket, Path),
            keep_alive;
       'HEAD' ->
            head_response(Socket, Path),
            keep_alive;
        _ ->
            Response = hw_response:response405(),
            gen_tcp:send(Socket, Response),
            close
    end.

head_response1(Socket, Path) ->
    {_, RelPath} = Path,
    case (RelPath) of
         "/" ->
            case get_path("/") of
                {ok, FilePath} ->
                    Size = filelib:file_size(FilePath),
                    Type = get_content_type(FilePath),
                    gen_tcp:send(Socket, hw_response:response200(Size, Type)),
                    {ok, 200};
                {error, 403} -> %сказать что нет такого файла
                    gen_tcp:send(Socket, hw_response:response403()),
                    {error, 403}
            end;
        _ ->
            case get_path(RelPath) of
                {ok, FilePath} ->
                    Size = filelib:file_size(FilePath),
                    Type = get_content_type(FilePath),
                    gen_tcp:send(Socket, hw_response:response200(Size, Type)),
                    {ok, 200};
                {error, 404} -> %сказать что нет такого файла
                    gen_tcp:send(Socket, hw_response:response404()),
                    {error, 404}
            end
    end.

valid_path(PP) ->
    case string:tokens(PP, "?") of
        [P, Arg]->
            Path = http_uri:decode(P),
            List = filename:split(Path),
            case lists:member("..",List) of
                true ->
                    {error, 403};
            false ->
                {ok, Path}
            end;
        [P] ->
            Path = http_uri:decode(P),
            List = filename:split(Path),
                case lists:member("..",List) of
                    true ->
                        {error, 403};
                    false ->
                        {ok, Path}
                end
    end.

get_response(Socket, Path) ->
    {_, RelPath} = Path,
    case get_path(RelPath) of
        {200, FilePath, Type1} ->
            %проверить тип
            Size = filelib:file_size(FilePath),
            Type = get_content_type(Type1),
            gen_tcp:send(Socket, hw_response:response200(Size, Type)),
            file:sendfile(FilePath, Socket),
            {ok, 200};
        {error, 403} ->
            gen_tcp:send(Socket, hw_response:response403()),
            {error, 403};
        {error, 404} ->
            gen_tcp:send(Socket, hw_response:response404()),
            {error, 404};
        {error, 400} ->
            gen_tcp:send(Socket, hw_response:response404()),
            {error, 404}
        end.

head_response(Socket, Path) ->
    {_, RelPath} = Path,
    case get_path(RelPath) of
        {200, FilePath, Type1} ->
            %проверить тип
            Size = filelib:file_size(FilePath),
            Type = get_content_type(Type1),
            gen_tcp:send(Socket, hw_response:response200(Size, Type)),
            {ok, 200};
        {error, 403} ->
            gen_tcp:send(Socket, hw_response:response403()),
            {error, 403};
        {error, 404} ->
            gen_tcp:send(Socket, hw_response:response404()),
            {error, 404};
        {error, 400} ->
            gen_tcp:send(Socket, hw_response:response404()),
            {error, 404}
        end.


get_path(P) ->
    case valid_path(P) of
        {error, 403} ->
            {error, 403};
        {ok, Path} ->
            FilePath = ?DOCUMENT_ROOT ++ Path,
            case filelib:is_dir(FilePath) of
                true -> 
                    IndexPath = FilePath ++ "/" ++ ?FILE_INDEX,
                    case filelib:is_file(IndexPath) of
                        true ->
                            {200, IndexPath, filename:extension(IndexPath)};
                        false ->
                            {error, 403}
                        end;
                false -> 
                    case filelib:is_file(FilePath) of
                        true ->
                            {200, FilePath, filename:extension(FilePath)};
                        false ->
                            case filename:extension(FilePath) of
                                [] ->
                                    {error, 400};
                                _ ->
                                    {error, 404}
                            end
                    end
            end
    end.

get_content_type(Type) ->
    case (Type) of
        ".html" ->
            "text/html";
        ".htm" ->
            "text/html";
        ".css" ->
            "text/css";
        ".js" ->
            "application/javascript";
        ".jpg" -> 
            "image/jpeg";
        ".jpeg" ->
            "image/jpeg";
        ".png" ->
            "image/png";
        ".gif" ->
            "image/gif";
        ".swf" ->
            "application/x-shockwave-flash";
        _ ->
            "application/octet-stream"
    end.

