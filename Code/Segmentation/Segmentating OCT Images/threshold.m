function image = threshold( im )
im_thresh = multithresh(im,6);
q = imquantize(im,im_thresh);
bw = edge(q,'prewitt');
image = bw;
end

