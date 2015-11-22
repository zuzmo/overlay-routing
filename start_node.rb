
node = ARGV[0]

# copy files to node
common_path = '/tmp/pycore.57337/'
nodes = {'n1' => 5, 'n2'=> 7, 'n3' => 9, 'n4' => 11}
system("cp -r ../overlay-routing/*.rb config weights.csv #{common_path}#{node}.conf/")

# start node
command = 'ruby node.rb config'
system("./ttyecho -n /dev/pts/#{nodes[node]} #{command} #{node}")
