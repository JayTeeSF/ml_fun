Train a model specify how-many iterations
(it secretly uses data.txt for supervised-learning of one-input and one-output):
./model_trainer.rb --iterations 100

Train and use a model (pass in a list of X test-values or it will re-use training values):
./model_trainer.rb --iterations 100 -1 0 1 2 3 4

Specify the weight and bias of a trained linear model
(optional test-values for X are also allowed):
./linear_model.rb 2.998 1.005

data.txt must be formatted as (you supply the inputs and answers):
X: [<1st-input>, ...<last-input>]
Y: [<1st-answer>, ...<last-answer>]

> cat data.txt # to see the expected Y values...

Linear model can train with vectors or scalars, though vector training is faster:
10K runs are 647ms vs 1.719s
