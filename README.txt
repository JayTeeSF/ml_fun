Train a model specify how-many iterations:
./learn_model.rb --iterations 100

Train and use a model (pass in a list of X values):
./learn_model.rb --iterations 100 -1 0 1 2 3 4

# cat data.txt to see the expected Y values...

Use a trained model pass-in the weight and bias (optionally followed by a list of X values):
./learn_model.rb 2.398 2.005 -1 0 1 2 3 4
