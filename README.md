Welcome to Deja.rb
==================
This is an ORM for Neo4j using Cypher over REST. The goal of this project is to create a light ORM that implements basic CRUD operations for Neo4J using an ActiveRecord style interface.

Deja relies on the [Neography library](https://github.com/maxdemarzi/neography) by [Max Demarzi](http://maxdemarzi.com/) for communicating with Neo4j over its REST interface. We will use solely Cypher in this library, but inclusion of Neography affords us access to the full range of REST traversal methods.


It also makes use of the [Neo4j-Cypher gem](https://github.com/andreasronge/neo4j-cypher) by Andreas Ronge as a simple DSL for the Cypher query language.


Setup:
-----
To setup use deja just require it in your project.
  ```ruby
  require 'deja'
  ```
Models:
------
To implement a model using Deja, inherit from Deja::Node
  ```ruby
  class Person < Deja::Node
    attr_accessor :name, :permalink, :type

    relationship :invested_in, :out => investment, :in => investor
    relationship :friends, :out => friend
    relationship :hates, :out => hates
  end
  ```
Relationship Structure:
-----------------------
Relationships are returned as the end node of a given relationship.
  ```ruby
  Person.friends.each do |friend|
    puts friend                    # returns the related Node
  end
  ```

Both plural and singular methods are generated for every relationship - the singular form returning the first node from the plural method. It accepts the same options as plural.
  ```ruby
  Company.address(:offset => 5)    # returns the 5th address node
  ```

Interface:
----------
### Loading Nodes:
To load a node with a given id, use the **find** method:
  ```ruby
  Person.find(3, :include => :none)     # does not include any related nodes
  ```
To load a person with a given id, and eager load a specific relationship, use the **:include** option:
  ```ruby
  Person.find(3, :include => :invested_in)
  ```
To load a node with a given id, and eager load all related nodes, use the **:all** argument:
  ```ruby
  Person.find(3, :include => :all)
  ```

### Loading Relationships:
To load a relationship with a given id, use the **find** method:
  ```ruby
  friend_rel = FriendsWith.find(5)
  friend_rel.start_node   # returns the beginning node
  friend_rel.end_node     # returns the ending node
  ```

### Saving Nodes:
To save a node, simply call the **save** method on that node, if you are editing a node from the graph, it will update the graph, if the node has not yet been saved to the graph, the node will be created.
  ```ruby
  node = Person.new()
  node.name      = "Mark Twain"
  node.permalink = "mark_twain"
  node.type      = "Person"
  node.save
  ```
### Deleting Nodes:
To delete a node from the graph, call the **delete** method on the node.
  ```ruby
  node = Person.load(3)
  node.delete
  ```
### Lazy Loading:
By default Deja supports lazy loading. To load a given relationship on the fly, simply call method with the same name as the relationship. Deja by default will always reload the relationship each time the method is called
  ```ruby
  node = Person.load(3)
  node.investments.each do |investment|       # fetches the investments from the graph
    investment.class                          # returns the Investment node object
  end
  ```
To load a relationship you use the link method:
  ```ruby
  node.link(:investments).each do |rel|
    rel.class                                 # returns the InvestedIn relationship object
  end
  ```
### Count:
To count the number of related nodes without actually fetching them, call the count method passing in the name of the relationship alias as an argument.
  ```ruby
  node.count(:investments)                    # returns the total count of all investments
  ```

### Order:
To order by a given property on end nodes of a relationship, pass an order option into the relationship alias method.
  ```ruby
  node.investments(:order => 'name ASC')      # returns the related nodes ordered by name
  ```

### Limit:
To limit the results of relationship load query, pass in a limit argument.
  ```ruby
  node.investments(:limit => 10)              # returns only the first 10 investments
  ```

### Offset:
To offset the results of relationship load query, pass in a offset argument.
  ```ruby
  node.investments(:offset => 5)              # returns all investments offset by the first 5
  ```

### Where:
To filter the related nodes based on node property values, use the ```:where``` option
  ```ruby
  node.investments(:where => { :terms => 'cash' })    # returns all investments that are 'cash' (only supports string values at the moment)
  ```

### Filter:
To filter the related nodes based on relationship property values, use the ```:filter``` option
  ```ruby
  node.investments(:filter => { :show => 'true' })    # returns all investments have show property set to true (only supports string values at the moment)
  ```

### Index Methods:
Deja allows you to create indexes for both nodes and relationships.
  ```ruby
  Deja.create_node_index('idx_Person')
  Deja.create_relationship_index('idx_FriendsWith')
  ```

Deja also supports finding by index
  ```ruby
  Person.find({:index => 'idx_Person', :key => :permalink, :value => 'john_smith'})
  ```
And for relationships
  ```ruby
  FriendsWith.find({:index => 'idx_FriendsWith', :key => 'permalink', :value => 'john_and_mary'})
  ```

Deja also supports a where method, which is a convenience for index searches:
  ```ruby
  Person.where(:permalink, 'john_smith')  # searches the idx_Person index for permalink of john_smith
  ```


