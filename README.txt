### Train a model (using supervised learning). Optionally specify how-many iterations (10K default)
X and Y values are stored (by default) in training_data.txt:

./bin/model_trainer.rb --iterations 100 [--weight <starting_weight>] [--bias <starting_bias>] [--learning_rate <learning_rate>] [--training_data_path <path/to/training_data:./data/training_data.txt>] [--good_enough <a fraction indicating how-little-loss is acceptable:0.001>]
e.g.
./bin/model_trainer.rb --learning_rate 0.0001 --bias 0 --weight 0

### Specify the weight and bias of a trained (linear) model. 
X and Y values are stored (by default) in testing_data.txt
(optionally override test-values for X and Y by passing an even number of values):

./bin/model_tester.rb <learned_weight> <learned_bias> [--test_data_path <path/to/test_data:./data/test_data.txt>]
e.g.
./bin/model_tester.rb 2.998 1.005

### training_data.txt (and test_data.txt) must be formatted as:
X: [<1st-input>, ...<last-input>]
Y: [<1st-answer>, ...<last-answer>]

> cat ./data/training_data.txt

## TBD(s):

NonLinearModel(s):
  (x - h)**2 + (y - k)**2 = r**2
  h,k is the center of the cirle
   r is the radius
  write a model to "learn" those hyperparameters (assuming that's possible)
   given that various points on the circle have multiple values !?!

## Learnings:

Linear model can train with vectors or scalars, though vector training is faster:
10K runs are 647ms vs 1.719s
also because the original scalar trainer trained each value separately, it was less accurate
it was essentially overfitting each individual x -> y mapping
causing each iteration to make a move that may have been "better" for that individual mapping, but "worse" for the overal model

