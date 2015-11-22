
# start all nodes by using ttyecho
nodes = {'n1' => 5, 'n2' => 7, 'n3' => 9, 'n4' => 11}
command = 'shutdown'
nodes.keys.each{ |n| system("./ttyecho -n /dev/pts/#{nodes[n]} #{command}")}
