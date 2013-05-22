require 'rake/testtask'

describe Bridge do
  before :each do
    @investment = Node.new({
      :id => 36,
      :name => 'Investment',
      :relationships => [{
        :recieved_investment => nil
        :direction => 'outgoing'
      },
      {
        :made_investment => nil,
        :direciton => 'outgoing'
      }]
    })
    @related_node = Node.new({
      :id => 5,
      :name => 'enigma',
      :permalink => 'enigma',
      :relationships => [{
          :recieved_investment => @investment,
          :direction => 'incoming'
      }]
    })
    @node = Node.new({
      :id => 3,
      :name => 'crunchbase',
      :permalink => 'cruncbase',
      :relationships => [{
        :made_investment => @investment
      }]
    })

    @investment[:relationships][0][:recieved_investment] = @related_node
    @investment[:relationships][1][:made_investment] = @node

  end
  describe ".get_all_related_nodes"
    subject { node }

    context "with node id" do

    end






  end
end
