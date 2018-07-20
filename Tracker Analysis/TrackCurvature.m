function [Curvature] = TrackCurvature(Traces)
%%

h = waitbar(0, 'Calculating curvature');
Curvature.raw = cell(1, size(Traces,2));
Curvature.max = cell(1,size(Traces,2));
for i = 1:size(Traces,2)
    if ~isempty(Traces{i})
        for j = 1:size(Traces{i},2)
            
            t = Traces{i}{j}; % get trace
            
            %{
            tax = 1:size(t,1); % t-axis
            fobjX = fit(tax',t(:,1),'poly2'); % find polynomial coefficients
            fobjY = fit(tax',t(:,2),'poly2');
            
            % Get 1st and 2nd derivatives of curve
            X_prime_1 = @(t) 2*fobjX.p1*t + fobjX.p2;
            X_prime_2 = 2*fobjX.p1;
            
            Y_prime_1 = @(t) 2*fobjY.p1*t + fobjY.p2;
            Y_prime_2 = 2*fobjY.p1;
            
            % function: Curvature as function of t
            k = @(t) abs( (X_prime_1(t)*Y_prime_2) - (Y_prime_1(t)*X_prime_2))./ ...
                ( (X_prime_1(t).^2 + Y_prime_1(t).^2).^(3/2));
            
            Curvature.raw{i}{j} = k(tax);
            Curvature.max{i}(j) = max(k(tax));
            Curvature.sum{i}(j) = sum(k(tax))/length(tax);
            %}
            v1 = t(5,:) - t(1,:);
            v2 = t(end,:) - t(end-5,:);
            A1 = atan2d(v1(2), v1(1));
            A2 = atan2d(v2(2), v1(1));
            
            angle = abs(A2 - A1);
            idx = find(angle > 180);
            angle(idx) = abs(angle(idx)-360);
            Curvature.theta{i}(j) = angle;
            
            
            
            
            
        end
    end
    waitbar(i/size(Traces,2))
end
close(h)

