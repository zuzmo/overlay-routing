
# copy code to all core nodes
common_path = '/tmp/pycore.57337/'
nodes = [['n1',5], ['n2',7], ['n3',9], ['n4',11]]
nodes.each { |n| system("cp -r ../overlay-routing/*.rb config weights.csv #{common_path}#{n[0]}.conf/")}

# start all nodes by using ttyecho
command = 'ruby node.rb config'
nodes.each{ |n| system("./ttyecho -n /dev/pts/#{n[1]} #{command} #{n[0]}")}

# command = 'clear'
# nodes.each{ |n| system("./ttyecho -n /dev/pts/#{n[1]} #{command}")}