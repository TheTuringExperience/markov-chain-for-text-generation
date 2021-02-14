$MULTIPLIER = 0.42 # this number most be chosen carefully to enable a uniform distribution of hashes

class Prefix
  attr_reader :nPref, :pref

  def initialize(args)
    if args["prefix"] then
      @pref = args["prefix"].clone
    else
      @nPref = args["nPref"]
      @pref = Array.new()
      for i in 0..@nPref-1
        @pref[i] = args["pref"]
      end            
    end    
  end

end

class Chain

  def initialize
    @NPREF = 2
    @NONWORD = "<endoftext>" # the "word" that can't appear
    @statetab = Hash.new()
    @prefix = Prefix.new({"nPref"=>@NPREF, "pref"=>@NONWORD}) # initial prefix
  end

  def add(word)    
    pref = @prefix.pref.clone()
    suf = @statetab[pref]    
    if suf == nil then
      suf = Array.new()
    end
    suf.push(word)    
    @statetab[pref] = suf
    @prefix.pref.delete_at(0)
    @prefix.pref.push(word)
  end

  def build(inputText)
    tokens = inputText.split(" ")
    for i in 0...tokens.size()
      add(tokens[i])
      if tokens[i] == @NONWORD then
        break
      end
    end
  end

  def generate(nWords)
    prefix =  Prefix.new({"nPref"=>@NPREF, "pref"=>@NONWORD})
    for i in 0...nWords
      states = @statetab[prefix.pref]      
      r = rand(states.size())
      suf = states[r]      
      if (suf == @NONWORD) then
        break
      end
      print (suf + " ")
      prefix.pref.delete_at(0)
      prefix.pref.push(suf)
    end
    print ("\n")
  end

end

$MAXGEN = 1000
inputFile = ARGV[0]

if inputFile then
  inputText = File.open("./#{inputFile}").read
else 
  inputText = File.open("./markov_chains.txt").read
end

inputText.gsub("\n", "<endoftext>")
inputText.concat("<endoftext>")
chain = Chain.new()
chain.build(inputText)
chain.generate($MAXGEN)
