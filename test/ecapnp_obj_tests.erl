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

-module(ecapnp_obj_tests).
-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-include("include/ecapnp.hrl").

-import(ecapnp_test_utils, [data/1]).

from_ref_test() ->
    Data = data([<<0,0,0,0, 2,0,3,0>>]),
    Ref = ecapnp_ref:get(0, 0, Data),
    ?assertEqual(
       #object{ ref=Ref, type=object },
       ecapnp_obj:from_ref(Ref, object)).

field_test() ->
    Data = data([]),
    {ok, T} = ecapnp_schema:lookup('Test', Data),
    ?assertEqual(
       #data{ type=uint32, align=32, default=12345 },
       ecapnp_obj:field(intField, #object{ type=T })).

copy_test() ->
    Bin = <<0,0,0,0, 2,0,2,0,
            1234:32/integer, 5678:32/integer,
            8765:32/integer, 4321:32/integer,
            0:64/integer,
            1,0,0,0, 106,0,0,0,
            "Hello World!", 0,
            0:24/integer
          >>,
    Data = data([Bin]),
    Ref = ecapnp_ref:get(0, 0, Data),
    Obj = ecapnp_obj:from_ref(Ref, object),
    ?assertEqual(#object{ type=object, ref=Ref }, Obj),
    ?assertEqual(Bin, ecapnp_obj:copy(Obj)).

-endif.