function [pt,pitchMask] = postPitchProcess(pitchContourIn,pitchMask0,nChan,gender)

if strcmp(gender,'f')
    pRange = [50 110];
elseif strcmp(gender,'m')
    pRange = [70,180]; % [50 110]
end

if pitchContourIn(1,1) == 0
    pt = 0;
    pitchMask = zeros(nChan, pitchContourIn(1,2));
    disp('0 Pitch detected!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
    return;
end

% correction
count = 2;
for k = 2:size(pitchContourIn,1)
    if sum(pitchContourIn(k,:))~=0
        pitchContourIn1(count,:)=pitchContourIn(k,:);
        count = count + 1;
    end
end
pitchContourIn1(1,1:2) = [size(pitchContourIn1,1)-1, size(pitchContourIn1,2)];
nContour = pitchContourIn1(1,1);
nRow = size(pitchContourIn1,1);
nFrame = pitchContourIn1(1,2);

% produce real contours
count = 2;
for k = 2:nRow
    tmpPC = pitchContourIn1(k,:);
    len1 = sum(tmpPC>0);
    t1 = find(tmpPC,1,'first');
    t2 = find(tmpPC,1,'last');
    len2 = t2-t1+1;
    if len1~=len2 % 0's in contour
        pos = find(abs(diff(sign([tmpPC,0])))==1);
        for k=1:length(pos)/2        
            tfs = pos(2*(k-1)+1)+1:pos(2*k);
            pitchContour0(count,:) = zeros(1,nFrame);
            pitchContour0(count,tfs) = tmpPC(tfs);           
            count = count + 1;
        end
    else
        pitchContour0(count,:) = tmpPC;
        count = count + 1;
    end
end
pitchContour0(1,1:2) = [size(pitchContour0,1)-1,size(pitchContour0,2)];
nContour = size(pitchContour0,1)-1;

% rule out wrong contours
count=1;
pitchMaskLen = zeros(1,nContour);
pitchContour(1,:)= zeros(1,nFrame);
for k = 1:nContour
    contour = pitchContour0(k+1,:);
    ind = (contour>0);
    pitchMaskLen(k) = sum(ind);
   
    diffContour = diff(contour((contour>0)));
    zeroRatio = sum(diffContour==0)/sum(contour>0);   
    wrongLen = sum((contour(ind)>pRange(2)))+sum((contour(ind)<pRange(1)));
    if zeroRatio<0.6 && wrongLen/pitchMaskLen(k) < 0.5 % some robustness
        contour(contour>pRange(2)) = 0;
        contour(contour<pRange(1)) = 0;
        pitchContour(count,:) = contour;
        pInd(count) = k+1; % valid contour indices
        count = count+1;
    end
end

% create index for mask
nonoverlapping = find(sum(sign(pitchContour))==1);
maskInd = zeros(1,nFrame);
for k = 1:length(nonoverlapping)
    for n = 1:size(pitchContour,1)
        if pitchContour(n,nonoverlapping(k)) > 0
            maskInd(nonoverlapping(k)) = pInd(n);
        end
    end
end

% refining overlapping contours
test=sum(pitchContour>0);
ind=find(test>1);
while numel(ind)>0 && size(pitchContour,1)>1
    ind1=find(pitchContour(:,ind(1))>0); % index of overlapping frames
    pc1=pitchContour(ind1(1),:);
    pc2=pitchContour(ind1(2),:);
    pc_sign=sign(pc1)+sign(pc2);
    overlapping = find(pc_sign==2);
    judge = (sum(pc1>0) > sum(pc2>0));
    %rangeJudge = (sum(pc1(ind1(1),overlapping)>pRange(2))/length(pc1))<0.5;
    if judge
        pitchContour(ind1(2),overlapping)=0;
        maskInd(overlapping) = pInd(ind1(1));
    else
        pitchContour(ind1(1),overlapping)=0;
        maskInd(overlapping) = pInd(ind1(2));
    end
    test=sum(sign(pitchContour));
    ind=find(test>1);
end
if size(pitchContour,1)>1
    pc = sum(pitchContour);
else
    pc = pitchContour;
end
pc = pc(:,1:end-1); % remove the last frame for consistency
pt = reshape(pc,1,length(pc));

% create mask
pitchmask = zeros(nFrame,nChan);
for k = 1:length(maskInd)
    if maskInd(k)>0
        start = find(pitchContour0(maskInd(k),:),1,'first');
        pitchmask(k,:) = pitchMask0(sum(pitchMaskLen(1:maskInd(k)-2))+k-start+1,:);
    end
end   
pitchMask = (pitchmask>0);

fprintf('done.\n');
