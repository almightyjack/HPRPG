    function assembleBeasts(fileNameRoot)
   
    %if no target given, assume that called directly, else assume called by
    %master
   
    if nargin < 1
        disp('Insufficient inputs provided');
        addpath('../../../CoreRulebook/Data/Functions/');
        fileNameRoot = '../../Chapters/Beasts/';
 
    end
    
    f = readtable("Species.xlsx");
    f = sortrows(f);
    List = Species.empty;
    for i = 1:height(f)
        List(i) = Species(f.Name{i},f.Description{i},f.SpeciesPicture{i}, f.PicHeight(i)  );
    end
    
    opts = detectImportOptions("beasts.xlsx","NumHeaderLines",2);
    f = readtable("beasts.xlsx",opts);
    
    g = {'SpeciesOrder','Name','Species','Desription','Rating','Mind','Category','Unharmed','Bruised','Hurt','Injured','Wounded','Mangled','Fortitude','Fitness','Precision','Vitality','Charm','Deception','Insight','Intelligence','Willpower','Perception','Block','Dodge','Defy','Immune','Resistant','Susceptible','Languages','Armaments','Skills','Abilities'};
    f.Properties.VariableNames = g
    f = sortrows(f);
    h = height(f);
    
    
    for i = 1:h
        b = Beast(f(i,:));
        found = false;
        for j = 1:length(List)
           
           if strcmp(List(j).Name,b.Species)
               List(j).Beasts(end+1) = b;
               found = true;
           end
          
        end
       if found == false
           c = Species(b.Species,"",string.empty,0);
           c.Beasts(end+1) = b;
           List(end+1) = c;
       end
    end
    text = "";
    
    for i = 1:length(List)
        if length(List(i).Beasts) == 1
            List(i).Name = List(i).Beasts(1).Name;
        end
    end
    
    [~,I] = sort([List.Name]);
    List = List(I);
    for j = 1:length(List)
        L = length(List(j).Beasts);
        if L > 1
            
            entry = "\\species{" + List(j)  .Name + "}\n{\n";
            entry = entry + "\t" + prepareText(List(j).Description) + "\n}\n{\n";

            [~,I] = sort([List(j).Beasts.Order]);
             List(j).Beasts = List(j).Beasts(I);


            for k = 1:length(List(j).Beasts)
                List(j).Beasts(k).ImagePos = 1- (mod(k,2));
                List(j).Beasts(k)
                entry = entry + List(j).Beasts(k).print() + "\n\n\n";
            end
            entry = entry + "\n}";
            
%             entry = entry + "{" + num2str(List(j).HasImage) + "}";
%             entry = entry + "{" + List(j).Image + "}";
%             entry = entry + "{" + List(j).Height + "}";

            
            text = text + entry + "\n\n\n\n\n";
        end
        
        if L == 1
           text = text + List(j).Beasts(1).print(1) + "\n\n\n\n"; 
        end
    end
    
    
    targetName = fileNameRoot + "BeastList.tex";
    

    fullText = text;

    FID = fopen(targetName,'w');
    fprintf(FID, fullText);
    fclose(FID);
    
end