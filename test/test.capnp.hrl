%%% DO NOT EDIT, this file was generated.
-include_lib("ecapnp/include/ecapnp.hrl").

-compile({nowarn_unused_function, test/1}).
-compile({nowarn_unused_function, test/2}).
-compile({nowarn_unused_function, test/3}).
-compile({nowarn_unused_function, test/4}).

%% Write value to object field.
%% -spec test(set, Field::atom(), Value::term(), Object::#object{}) -> ok.
test(set, Field, Value, Object) ->
    ecapnp:set(Field, Value, Object).

%% Write unnamed union value
%% -spec test(set, {field_name(), field_value()}|field_name(), object()) -> ok.
test(set, Value, Object) ->
    ecapnp:set(Value, Object);

%% Get a reference to the root object in message.
%% -spec test(root, Type::atom() | integer(), Message::list(binary())) -> {ok, Root::#object{}}.
test(root, Type, Message) ->
    ecapnp:get_root(Type, test(schema), Message);

%% Read object field value.
%% -spec test(get, Field::atom(), Object::#object{}) -> term().
test(get, Field, Object) ->
    ecapnp:get(Field, Object);

%% Type cast object to another struct or list.
%% -spec test(to_struct, Type::atom() | integer(), Object1::#object{}) -> Object2#object{}.
%% -spec test(to_list, Type::atom() | integer(), Object::#object{}) -> list().
test(TypeCast, Type, Object)
  when TypeCast == to_struct;
       TypeCast == to_list ->
    ecapnp_obj:TypeCast(Type, Object).

%% Set root type for a new message.
%% -spec test(root, Type::atom() | integer()) -> {ok, Root::#object{}}.
test(root, Type) ->
    ecapnp:set_root(Type, test(schema));

%% Read unnamed union value of object.
%% -spec test(get, Object::#object{}) -> Tag::atom() | {Tag::atom(), Value::term()}.
test(get, Object) ->
    ecapnp:get(Object);

%% Type cast object to text/data.
%% -spec test(to_text | to_data, Object::#object{}) -> binary().
test(TypeCast, Object)
  when TypeCast == to_text;
       TypeCast == to_data ->
    ecapnp_obj:TypeCast(Object).

%% Get the compiled schema.
%% -spec test(schema) -> #schema{}.

test(schema) ->
  #schema_node{ %% 0xe87e0317861d75a1
      name=test, id=16752831063434032545, src= <<"test/test.capnp">>,
      kind=file,
      nodes=
        [#schema_node{ %% 0xfa556038e27b336d
           name='Test', id=18038429679936549741, src= <<"test/test.capnp:Test">>,
           kind=#struct{ dsize=2, psize=6, esize=inlineComposite,
               union_field=#data{ align=16, default= <<0,0>>, type=
                 {union,
                   [{0,boolField,
                     #data{ type=bool, align=15,
                            default= <<0:1>> }},
                    {1,groupField,
                     #group{ id=12591081617868223671 }}
                 ]}},
               fields=
                 [{intField,
                   #data{ type=uint8, align=0,
                          default= <<33>> }},
                  {textField,
                   #ptr{ type=text, idx=0,
                         default= <<"test">> }},
                  {opts,
                   #group{ id=9356761420570873088 }},
                  {meta,
                   #group{ id=12292473172826227401 }},
                  {structField,
                   #ptr{ type={struct,15091335337902283752}, idx=4,
                         default= <<0,0,0,0,0,0,0,0>> }}
                 ]},
           nodes=
             [#schema_node{ %% 0xaa97a338ed5382c9
                name=meta, id=12292473172826227401, src= <<"test/test.capnp:Test.meta">>,
                kind=#struct{ dsize=2, psize=6, esize=inlineComposite,
                    union_field=none,
                    fields=
                      [{id,
                        #data{ type=uint16, align=80,
                               default= <<0,0>> }},
                       {tag,
                        #ptr{ type=text, idx=2,
                              default= <<>> }},
                       {data,
                        #ptr{ type=data, idx=3,
                              default= <<49,50,51,52>> }},
                       {struct,
                        #ptr{ type={struct,15091335337902283752}, idx=5,
                              default= <<0,0,0,0,1,0,2,0,0,0,0,0,12,0,0,0,5,0,
                                         0,0,210,0,0,0,0,0,0,0,0,0,0,0,111,118,
                                         101,114,114,105,100,101,110,32,100,
                                         101,102,97,117,108,116,32,109,101,115,
                                         115,97,103,101,0,0,0,0,0,0,0>> }}
                      ]}},
              #schema_node{ %% 0x81d9e4f01134cd00
                name=opts, id=9356761420570873088, src= <<"test/test.capnp:Test.opts">>,
                kind=#struct{ dsize=2, psize=6, esize=inlineComposite,
                    union_field=#data{ align=64, default= <<0,0>>, type=
                      {union,
                        [{0,bool,
                          #data{ type=bool, align=55,
                                 default= <<1:1>> }},
                         {1,text,
                          #ptr{ type=text, idx=1,
                                default= <<>> }},
                         {2,data,
                          #ptr{ type=data, idx=1,
                                default= <<>> }},
                         {3,object,
                          #ptr{ type=object, idx=1,
                                default= <<0,0,0,0,0,0,0,0>> }}
                      ]}}}},
              #schema_node{ %% 0xaebc820562fc74b7
                name=groupField, id=12591081617868223671, src= <<"test/test.capnp:Test.groupField">>,
                kind=#struct{ dsize=2, psize=6, esize=inlineComposite,
                    union_field=none,
                    fields=
                      [{a,
                        #data{ type=int8, align=8,
                               default= <<212>> }},
                       {b,
                        #data{ type=int8, align=32,
                               default= <<55>> }},
                       {c,
                        #data{ type=int8, align=40,
                               default= <<0>> }}
                      ]}}
             ]},
         #schema_node{ %% 0xd16f318851f71be8
           name='Simple', id=15091335337902283752, src= <<"test/test.capnp:Simple">>,
           kind=#struct{ dsize=1, psize=2, esize=inlineComposite,
               union_field=none,
               fields=
                 [{message,
                   #ptr{ type=text, idx=0,
                         default= <<"default message">> }},
                  {value,
                   #data{ type=uint32, align=0,
                          default= <<222,0,0,0>> }},
                  {simpleMessage,
                   #ptr{ type=text, idx=1,
                         default= <<"simple message">> }},
                  {defaultValue,
                   #data{ type=uint32, align=32,
                          default= <<77,1,0,0>> }}
                 ]}},
         #schema_node{ %% 0xed15f6a91b7977a6
           name='ListTest', id=17083831967670695846, src= <<"test/test.capnp:ListTest">>,
           kind=#struct{ dsize=0, psize=4, esize=inlineComposite,
               union_field=none,
               fields=
                 [{listInts,
                   #ptr{ type={list,int32}, idx=0,
                         default= <<1,0,0,0,28,0,0,0,200,1,0,0,21,3,0,0,133,
                                    255,255,255,0,0,0,0>> }},
                  {listAny,
                   #ptr{ type=object, idx=1,
                         default= <<0,0,0,0,0,0,0,0>> }},
                  {listSimples,
                   #ptr{ type={list,{struct,15091335337902283752}}, idx=2,
                         default= <<1,0,0,0,55,0,0,0,8,0,0,0,1,0,2,0,223,0,0,0,
                                    0,0,0,0,17,0,0,0,50,0,0,0,0,0,0,0,0,0,0,0,
                                    220,0,0,0,0,0,0,0,9,0,0,0,58,0,0,0,0,0,0,0,
                                    0,0,0,0,102,105,114,115,116,0,0,0,115,101,
                                    99,111,110,100,0,0>> }},
                  {listText,
                   #ptr{ type={list,text}, idx=3,
                         default= <<0,0,0,0,0,0,0,0>> }}
                 ]}}
        ]}.
