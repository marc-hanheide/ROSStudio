cmd_Debug/obj.target/gzbridge.node := g++ -shared -pthread -rdynamic -m64 -L/usr/local/lib -L/usr/lib/x86_64-linux-gnu/gazebo-9/plugins -Wl,-rpath,/usr/lib/x86_64-linux-gnu/gazebo-9/plugins  -Wl,-soname=gzbridge.node -o Debug/obj.target/gzbridge.node -Wl,--start-group Debug/obj.target/gzbridge/GZNode.o Debug/obj.target/gzbridge/GazeboInterface.o Debug/obj.target/gzbridge/pb2json.o Debug/obj.target/gzbridge/ConfigLoader.o Debug/obj.target/gzbridge/OgreMaterialParser.o -Wl,--end-group -lgazebo_transport -lgazebo_physics -lgazebo_sensors -lgazebo_rendering -lgazebo_gui -lgazebo_client -lgazebo_msgs -lgazebo_common -lgazebo -lboost_thread -lboost_signals -lboost_system -lboost_filesystem -lboost_program_options -lboost_regex -lboost_iostreams -lboost_date_time -lboost_chrono -lboost_atomic -lpthread -lsdformat -ltbb -latomic -lignition-transport4 -luuid -lignition-msgs1 -lignition-math4 -lignition-fuel_tools1 -ljansson -lprotobuf
