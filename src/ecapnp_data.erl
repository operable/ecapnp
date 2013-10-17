%%  
%%  Copyright 2013, Andreas Stenius <kaos@astekk.se>
%%  
%%   Licensed under the Apache License, Version 2.0 (the "License");
%%   you may not use this file except in compliance with the License.
%%   You may obtain a copy of the License at
%%  
%%     http://www.apache.org/licenses/LICENSE-2.0
%%  
%%   Unless required by applicable law or agreed to in writing, software
%%   distributed under the License is distributed on an "AS IS" BASIS,
%%   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%   See the License for the specific language governing permissions and
%%   limitations under the License.
%%  

%% @copyright 2013, Andreas Stenius
%% @author Andreas Stenius <kaos@astekk.se>
%% @doc Data server module
%%
%% All objects data is held in a data process, implemented by this
%% module.
%%
%% I have a wish to get away with the fact that each reference to
%% default data ends up with their own separate data process.

-module(ecapnp_data).
-author("Andreas Stenius <kaos@astekk.se>").

-export([new/1, alloc/3, update_segment/3,
         get_segment/4, get_segment_size/2,
         get_message/1, get_type/2]).

-include("ecapnp.hrl").


%% ===================================================================
%% API functions
%% ===================================================================

%% @doc Start a new data process.
-spec new(#msg{}
          |{schema(), SegmentSize::integer()}
          |{pid(), Data::binary()}) -> pid().
new(Init) ->
    spawn_link(fun() -> data_state(Init) end).

%% @doc Allocate data.
%%
%% Preferably from segment id `Id', if possible.  This will rarely
%% fail, as new segments are added in case there is not enough free
%% space left.
-spec alloc(segment_id(), integer(), pid()) -> {segment_id(), Offset::integer()}.
alloc(Id, Size, Pid) 
  when is_integer(Id), is_integer(Size) ->
    data_request(alloc, {Id, Size}, Pid).

%% @doc Write data to segment.
-spec update_segment({segment_id(), integer()}, binary(), pid()) -> ok.
update_segment({Id, Offset}, Data, Pid)
  when is_integer(Id), is_integer(Offset), is_binary(Data) ->
    data_request(update_segment, {Id, Offset, Data}, Pid).

%% @doc Read data from segment.
-spec get_segment(segment_id(), integer(), integer(), pid()) -> binary().
get_segment(Id, Offset, Length, Pid)
  when is_integer(Id), is_integer(Offset) andalso
       is_integer(Length); Length == all ->
    data_request(get_segment, {Id, Offset, Length}, Pid).

%% @doc Get size of segment, in words (8 bytes).
-spec get_segment_size(segment_id(), pid()) -> integer().
get_segment_size(Id, Pid) ->
    data_request(get_segment_size, Id, Pid).

%% @doc Get the data process message record.
-spec get_message(pid()) -> #msg{}.
get_message(Pid) ->
    data_request(get_message, [], Pid).

%% @doc Lookup type in schema.
-spec get_type(schema_type(), pid()) -> node_type() | false.
get_type(Type, Pid)
  when is_atom(Type);
       is_integer(Type) ->
    data_request(get_type, Type, Pid).


%% ===================================================================
%% internal functions
%% ===================================================================

empty_message(Size) -> [empty_segment(Size)].
empty_segment(Size) -> <<0:Size/integer-unit:64>>.

data_request(Request, Args, Pid) 
  when is_pid(Pid) ->
    Pid ! {self(), Request, Args},
    receive
        {Request, Result} -> Result
    after 5000 -> timeout
    end.


%% ===================================================================
%% Data state functions, should only be called from the data process
%% ===================================================================

-record(state, { msg, nodes }).

data_state(State)
  when is_record(State, state) ->
    receive
        {From, Request, Args} ->
            handle_response(
              handle_request(Request, Args, State),
              {Request, From})
    end;

data_state(Message)
  when is_record(Message, msg) ->
    data_state(new_state(Message));
data_state({Pid, Data}) when is_pid(Pid), is_binary(Data) ->
    Msg = get_message(Pid),
    data_state(Msg#msg{
                 alloc=[size(Data)],
                 data=[Data]
                });
data_state({Schema, MsgSize})
  when is_integer(MsgSize) andalso
       (is_list(Schema)
        orelse is_record(Schema, schema_node)) ->
    data_state(new_state(#msg{ 
                            schema=Schema, 
                            alloc=[0],
                            data=empty_message(MsgSize)
                           })).

new_state(#msg{ schema=Schema }=Msg) ->
    #state{
       msg=Msg,
       nodes=list_nodes(Schema, [])
      }.

list_nodes([#schema_node{ nodes=Nodes }=T|Ts], Acc) ->
    list_nodes(Nodes, list_nodes(Ts, [T|Acc]));
list_nodes([Import|Ts], Acc) when is_list(Import) ->
    list_nodes(Ts, list_nodes(Import, Acc));
list_nodes(_, Acc) -> Acc.



handle_response({Response, State}, {Request, From}) ->
    From ! {Request, Response},
    data_state(State);
handle_response(State, {Request, From}) ->
    From ! {Request, ok},
    data_state(State).
    
handle_request(alloc, {Id, Size}, State) ->
    do_alloc(Id, Size, State);
handle_request(update_segment, {Id, Offset, Data}, State) ->
    do_update_segment(Id, Offset, Data, State);
handle_request(get_segment, {Id, Offset, Length}, State) ->
    do_get_segment(Id, Offset, Length, State);
handle_request(get_segment_size, Id, State) ->
    do_get_segment_size(Id, State);
handle_request(get_message, _, State) ->
    {State#state.msg, State};
handle_request(get_type, Type, State) ->
    do_get_type(Type, State);
handle_request(Req, _Args, State) ->
    {{bad_request, Req}, State}.

                             
do_alloc([Id|Ids], Size, State0) ->
    case do_alloc_data(Id, Size, State0) of
        {false, State} -> do_alloc(Ids, Size, State);
        Result -> Result
    end;
do_alloc([], _Size, State) ->
    {false, State}; %% TODO: add new segment
                     
do_alloc(Id, Size, State) ->
    case do_alloc_data(Id, Size, State) of
        {false, State} ->
            do_alloc_data(
              lists:seq(0, segment_count(State) - 1) -- [Id],
              Size, State);
        Result -> Result
    end.
    
do_alloc_data(Id, Size, State) ->
    Segment = get_segment(Id, State),
    SegSize = size(Segment),
    Msg = State#state.msg,
    Alloc = Msg#msg.alloc,
    {PreA, [Alloced|PostA]} = lists:split(Id, Alloc),
    if Size =< (SegSize - Alloced) ->
            {{Id, Alloced}, 
             State#state{
               msg=Msg#msg{ 
                     alloc = PreA ++ [Alloced + Size|PostA] 
                    }}
            };
       true -> {false, State}
    end.

do_update_segment(Id, Offset, Data, State) ->
    Size = size(Data),
    <<Pre:Offset/binary-unit:64,
      _:Size/binary,
      Post/binary>> = get_segment(Id, State),
    set_segment(
      Id,
      <<Pre/binary,
        Data/binary, 
        Post/binary>>,
      State).

do_get_segment(Id, Offset, all, State) ->
    <<_:Offset/binary-unit:64,
      Segment/binary>> = get_segment(Id, State),
    {Segment, State};
do_get_segment(Id, Offset, Length, State) ->
    <<_:Offset/binary-unit:64,
      Segment:Length/binary-unit:64,
      _/binary>> = get_segment(Id, State),
    {Segment, State}.

do_get_segment_size(Id, State) ->
    {size(get_segment(Id, State)) div 8, State}.

do_get_type(Type, #state{ nodes=Ns }=State) when is_atom(Type) ->
    {lists:keyfind(Type, #schema_node.name, Ns), State};
do_get_type(Type, #state{ nodes=Ns }=State) when is_integer(Type) ->
    {lists:keyfind(Type, #schema_node.id, Ns), State}.


%% ===================================================================
%% Data utils
%% ===================================================================

get_segment(Id, #state{ msg=#msg{ data=Segments } }) ->
    lists:nth(Id + 1, Segments).

segment_count(#state{ msg=#msg{ alloc=List } }) ->
    length(List).

set_segment(Id, Segment, 
            #state{
               msg=#msg{
                      data=Segments }=Msg
              }=State) ->
    {Pre, [_|Post]} = lists:split(Id, Segments),
    State#state{ msg=Msg#msg{ data = Pre ++ [Segment|Post] } }.