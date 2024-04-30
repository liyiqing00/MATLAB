function PeakX=findSecondPeak(PeaksMap,PeakY,sort_ind,n)
count=0;
for x=sort_ind   
    if PeaksMap(PeakY,x)==1 %Peakであるとき
        PeakX=x;
        count=count+1;
    if count==n %第nのPeakになるとき
        break
    end
    end
end
end