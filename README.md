Welcome to Deja.rb
==================
This is an ORM for Neo4j using Cypher over REST. The goal of this project is to create a light ORM that implements basic CRUD operations for Neo4J using an ActiveRecord style interface.

Deja relies on the [Neography library](https://github.com/maxdemarzi/neography) by [Max Demarzi](http://maxdemarzi.com/) for communicating with Neo4j over its REST interface. We will use solely Cypher in this library, but inclusion of Neography affords us access to the full range of REST traversal methods.


It also makes use of the [Neo4j-Cypher gem](https://github.com/andreasronge/neo4j-cypher) by Andreas Ronge as a simple DSL for the Cypher query language.


Setup:
-----
To setup a rest endpoint to issue queries against, bind the Neography Rest object to Deja.neo.
  ```ruby
  Deja.neo = Neography::Rest.new()
  ```
Models:
------
To implement a model using Deja, inherit from Deja::Node
  ```ruby
  class Person < Deja::Node
    attr_accessor :name, :permalink, :type

    relationship :invested_in
    relationship :friends
    relationship :hates
  end
  ```
Relationship Structure:
-----------------------
Relationships are returned as (node/rel) pairs(Arrays). This allows us to iterate over both the relationship and the related node in the same step.
  ```ruby
  Person.friends.each do |node, rel|
    puts node                      # returns the related Node
    puts rel                       # returns the Relationship
  end
  ```

Both plural and singular methods are generated for every relationship - the singular form returning the first (node/rel) pair in the plural method. It accepts a block.
  ```ruby
  Company.address do |node, rel|
    puts node
    puts rel
  end
  ```

Interface:
----------
### Loading Nodes:
To load a node with a given id, use the **load** method:
  ```ruby
  Person.load(3)
  ```
To load a person with a given id, and eager load a specific relationship, use the **:include** option:
  ```ruby
  Person.load(3, :include => :invested_in)
  ```
To load a node with a given id, and eager load all related nodes, use the **:all** argument:
  ```ruby
  Person.load(3, :include => :all)
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
  node.invested_in.each do |investment, rel|  # fetches the investments from the graph
    investment.class                      # returns the Investment node object
    investment.rel.class                  # returns the InvestedIn relationship object
  end
  ```
