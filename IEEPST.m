  function  [result_2D] = IEEPST(X_cube, N_topo, per_ie)
% paper:¡¶Information Entropy Estimation Based on Point-Set Topology for Hyperspectral Anomaly Detection¡·
% Input:
% X_cube£ºan HSI being processed;  
% N_topo: the number of point sets in each topological space; per_ie: the percentage used to set the threshold to constrain the information entropy
% Output:
% result_2D: detection results

 
[samples,lines,band_num]=size(X_cube);
pixel_num = samples * lines;
X_use = reshape(X_cube,pixel_num,band_num);
X = X_use.'; 
clear('X_cube', 'X_use');


%% Construct parallel topological spaces
[chessboard_card, chessboard_cenvalue] = hist(X.', N_topo);
chessboard_card = chessboard_card.';
chessboard_cenvalue = chessboard_cenvalue.';
chessboard_cenvalue = repmat(chessboard_cenvalue,band_num,1);
probability_card = chessboard_card./pixel_num;


card_max = max(chessboard_card,[],2);


%%  Estimate information entropies
information_entropy = [];
for j = 1:band_num
information_entropy_j = 0;
     for m = 1:N_topo
        probability_card_j_m = probability_card(j,m);       
        if probability_card_j_m == 0
            information_entropy_j_m = 0;
        else
            information_entropy_j_m = - probability_card_j_m * log2(probability_card_j_m);   
        end
        information_entropy_j = information_entropy_j + information_entropy_j_m;
     end     
     
information_entropy = [information_entropy; information_entropy_j];
end
        


%% Sleect the optimal separable spaces 
information_entropy_interval = max(information_entropy) - min(information_entropy);
threshold_allbands = min(information_entropy) + per_ie * information_entropy_interval;   
index_for_AS_information_entropy_use_1 = find( information_entropy < threshold_allbands );   
index_for_AS_information_entropy_use_2 = find( information_entropy > 0 );   
OSS = intersect(index_for_AS_information_entropy_use_1, index_for_AS_information_entropy_use_2);

N_OSS = length(OSS); 
card_max_oss = card_max(OSS);

%% Perform anomaly detection
result = zeros(1, pixel_num);

for i = 1:pixel_num
    x = X(:,i);   
    
    card_x = [];
    
    for j = 1:N_OSS    
        
        k = OSS(j);      
        a = x(k);          
     
        chessboard_card_k = chessboard_card(k,:);
               
        [card_max_k, ~] = max(chessboard_card_k);
        X_dim_cen_k = chessboard_cenvalue(k,:);     
        [~, index_x] = min(abs(X_dim_cen_k(:) - a));
        x_k_cardinality = chessboard_card(k, index_x);   

        if x_k_cardinality == 0      
            x_k_cardinality = 1;     
        end 
           
        card_x = [card_x; x_k_cardinality];
                    
    end

    card_max_x_oss = card_max_oss./card_x;
    AS = mean(card_max_x_oss);
    result(i) = AS;        

end

r_255 = get_255(result);   
result_2D = reshape(r_255, samples, lines);   
         
end   


    
     




