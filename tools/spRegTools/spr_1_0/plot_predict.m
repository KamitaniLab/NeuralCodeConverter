% plot_predict

Tlim  = [200 500];

% Plot prediction for test data
plot(ytest')
hold on
plot(ypred','-.r')
xlim(Tlim)

%plot(Info.dID,'o')
return
