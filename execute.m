function issvecout = execute(a0, a1, targetcode, profilemode)
% This script will run two different version of the Volterra Adaptive filter 
% These are
% 1. Matlab native m-code
% 2. using the ISS (via xt-run) command
% 
% The script will compile the targetcode before running xtrun.
% The script relies on 3 global variables that will be used
% for controlling xt-xcc and xt-run: XTENSATOOLS, XTENSACORE and XTENSASYSTEM
% There is one output: the error issvecout.
% There are 4 inputs: 
% 1/2. the two input vectors 
% 3. The name of the target code to compile/run (Note: this is assumed to be in the current MATLAB working directory)
% 4. a profilemode string which will indicate what level of profiling of the target code running on the ISS will be used:
%    'simple' or 'full'

global XTENSATOOLS XTENSACORE XTENSASYSTEM INCLUDE;

% Basic checking that number of input and output arguments is correct.
if (nargin ~= 4)
    error('Must have 4 input arguments: two vectors, targetcode, profilemode');
end
if (nargout ~= 1)
    error('Must have 1 output argument.');
end
% Input checks. Check that "targetcode" has something in it and
% that profilemode is one of the two correct options.
if (strcmp(targetcode, ''))
    error('targetcode input argument must have name in it.');
end
if (~strcmp(profilemode, 'simple') && ~strcmp(profilemode, 'full'))
    error('profilemode input argument must be either "simple" or "full".');
end

% dump the two input vectors via the function "exporttwovectors".
% Intermediate file will be called 'twovecinput.txt'
exporttwovectors(a0,a1,'twovecinput.txt');

% compile the target programme via Matlab unix function "unix". Output file
% by default will be "a.out". If the compile fails then the return
% code will be non-zero.
[retcode,result] = unix(strcat([XTENSATOOLS,'\xt-xcc ',targetcode,' --xtensa-system=',XTENSASYSTEM,' --xtensa-core=',XTENSACORE,' --include-directory ',INCLUDE]));
if (retcode ~= 0)
	error(strcat('compilation of targetcode failed SYSTEM:',result));
end
% set up profiling options. Profile output file will be called
% "myprof"
if strcmp(profilemode, 'simple')
	profilestring = '--clientcommands=profile --disable myprof';
end
if strcmp(profilemode, 'full')
	profilestring = '--clientcommands=profile --disable --instructions --cycles --icmiss --dcmiss --icmiss-cycles --dcmiss-cycles --branch-delay --interlock myprof';
end
% remember that --memmodel option is needed for xt-run, and to put "
% around profilestring
% run xt-run. The output file created is onevecoutput.txt
[retcode,result] = unix(strcat([XTENSATOOLS,'\xt-run --memmodel "',profilestring,'" --xtensa-system=',XTENSASYSTEM,' --xtensa-core=',XTENSACORE,' a.out twovecinput.txt onevecoutput.txt']));
if (retcode ~= 0)
	error(strcat('running of ISS on target code failed SYSTEM:',result));
end
% Now bring in the output vector using the inbuilt Matlab function
% "importdata". This comes in as a single column vector, not a single row
% vector, so we take its transpose using the Matlab syntax ".'".
% We also ensure it is an inte32 vector
issvecout = single(importdata('onevecoutput.txt').');

end
