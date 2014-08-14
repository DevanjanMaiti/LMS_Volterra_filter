function exporttwovectors (a0, a1, filename)
% EXPORTTWOVECTORS will dump out two single dimensional column vectors a0 and a1
% of the same size side by side into file "filename"
% Uses fopen, fprintf, fclose.
% Basic check that number of input arguments is correct.
	if (nargin ~= 3)
		error('Must have 3 input arguments.');
	end
	% Basic check that number of output arguments is correct.
	if (nargout ~= 0)
		error('Must have 0 output arguments.');
	end
	% Create the output file with the name "filename"
	fid = fopen(filename,'w');
	if (fid == -1)
		error('Cannot create output file.')
	end
	% Check size dimensions of the two vectors to ensure they are correct
	[m0 ,n0] = size(a0);
	[m1 ,n1] = size(a1);
	if (n0 ~=1)
		error('First array is not a vector')
	end
	if (n1 ~=1)
		error('Second array is not a vector')
	end
	if (m0 < 1)
		error('First array is not a vector')
	end
	if (m1 < 1)
		error('Second array is not a vector')
	end
	if (m0 ~= m1)
		error('The two input vectors are not the same size')
	end
	% write out the size
	fprintf(fid,'%d\n',m0);
	% write out the two vectors, one value from each on each line, as integers
	for i = 1:m0
		fprintf(fid,'%f %f\n',a0(i,1), a1(i,1));
	end
	% close the output file
	fclose(fid);
end
