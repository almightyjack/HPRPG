classdef Beast

    properties
        Order
        Name
        Species
        Rating
        Mind
        Category
        
        Description
        
        Fitness
        Precision
        Vitality
        Charm
        Deception
        Insight
        Intelligence
        Willpower
        Perception
        
        Unharmed
        Bruised
        Hurt
        Injured
        Wounded
        Mangled
        
        Fortitude
        HasFortitude
        
        Block
        Dodge
        Defy
        
        SKills
        HasSkills
        
        Immune
        Resistant
        Susceptible
        
        
        Languages
        HasLanguages
        Armaments
        HasArmaments
        Skills
        Abilities
        
        Image
        HasImage
        ImagePos
        ImageHeight
        
        Article;
        
        NeedsPage
        
        IsHuge
        
        ImageStack
        Empty;
        
        WalkSpeed;
        FlySpeed;
        TunnelSpeed;
        SwimSpeed;
        ClimbSpeed;
        
        Movement;
    end
    
    methods
        function obj = Beast(tableLine)
            obj.Order = tableLine.SpeciesOrder(1);
            obj.Name = string(tableLine.Name{1});
            
            obj.Article = "A";
            if any(obj.Name(1) == ["A","E","I","O","U"])
               obj.Article = "An"; 
            end
            
            obj.Species = tableLine.Species{1};
            obj.Mind = tableLine.Mind{1};
            obj.Category = tableLine.Category{1};
            obj.Rating = num2roman(tableLine.Rating(1));
            obj.Description = tableLine.Description{1};
            
            obj.Unharmed = tableLine.Unharmed(1);
            obj.Bruised = tableLine.Bruised(1);
            obj.Hurt = tableLine.Hurt(1);
            obj.Injured = tableLine.Injured(1);
            obj.Wounded = tableLine.Wounded(1);
            obj.Mangled = tableLine.Mangled(1);
            
            obj.Fortitude = tableLine.Fortitude(1);
            obj.HasFortitude = true;
            if isnan(obj.Fortitude)
                obj.HasFortitude = false;
            end
            
            obj.Fitness = tableLine.Fitness(1);
            obj.Precision = tableLine.Precision(1);
            obj.Vitality = tableLine.Vitality(1);
            obj.Charm = tableLine.Charm(1);
            obj.Deception = tableLine.Deception(1);
            obj.Insight = tableLine.Insight(1);
            obj.Intelligence = tableLine.Intelligence(1);
            obj.Willpower = tableLine.Willpower(1);
            obj.Perception = tableLine.Perception(1);
            
            obj.Empty = obj.Fitness + obj.Precision + obj.Vitality + obj.Charm + obj.Deception + obj.Insight + obj.Intelligence + obj.Willpower + obj.Perception;
            
            obj.Block = tableLine.Block(1);
            obj.Defy = tableLine.Defy(1);
            obj.Dodge = tableLine.Dodge(1);
            
            obj.WalkSpeed = tableLine.Walk(1);
            obj.SwimSpeed = tableLine.Swim(1);
            obj.ClimbSpeed = tableLine.Climb(1);
            obj.FlySpeed = tableLine.Fly(1);
            obj.TunnelSpeed = tableLine.Tunnel(1);
            
            obj.Resistant = tableLine.Resistant{1};
            obj.Immune = tableLine.Immune{1};
            obj.Susceptible = tableLine.Susceptible{1};
            obj.Languages = tableLine.Languages{1};
            obj.HasLanguages = true;
            if (obj.Languages == "")
                obj.HasLanguages = false;
            end
            obj.Skills = tableLine.Skills{1};
            obj = obj.parseAbilities();
            obj.HasSkills = true;
            if (obj.Skills == "")
                obj.HasSkills = false;     
            end
            obj.Armaments = tableLine.Armaments{1};
            obj.HasArmaments = true;
            if(obj.Armaments == "")
                obj.HasArmaments = false;
            end
            obj.Abilities = tableLine.Abilities{1};
            
            obj.Image = tableLine.Image{1};
            obj.HasImage = true;
            if (obj.Image == "")
                obj.HasImage = false;
            end
            
            obj.ImageStack = tableLine.Stack(1);
        end
        
        function [text, added] = print(obj,mode,participants)
            if nargin < 2
                mode = 0;
            end
            added = 0;
            text = "";
            if obj.Empty > 0
                added = 1;
                text = "\\beast{";
                if mode == 1
                   text = "\\speciesBeast{"; 
                elseif mode == 2
                    text = "\\encounterBeast{";
                end

                titles = ["name", "species","mind","category","rating","abilities","article","movement"];
                array = [string(obj.Name), string(obj.Species), string(obj.Mind), string(obj.Category),string(obj.Rating),string(obj.Abilities),string(obj.Article),string(obj.Movement)];

                for i = 1:length(array)
                    text = text + prepareText(titles(i)) + " = " + prepareText(array(i)) + ", ";
                end

                text = text + obj.statBlock();
                text = text + obj.ResistanceText();
                numTitles = ["nUnharmed","nBruised","nHurt","nInjured","nWounded","nMangled","block","dodge","defy","fortitude","imageStack"];
                numArray = [obj.Unharmed, obj.Bruised, obj.Hurt, obj.Injured, obj.Wounded, obj.Mangled, obj.Block, obj.Dodge,obj.Defy,obj.Fortitude,obj.ImageStack];
                for i = 1:length(numArray)
                    val = numArray(i);
                    if isnan(val)
                        val = 0;
                    end
                    text = text + numTitles(i) + "="+num2str(val) + ", ";
                end

                hasTitles = ["hasSkills","hasAttacks","hasLanguages","hasImage"];
                hasTriggers = [obj.HasSkills,obj.HasArmaments,obj.HasLanguages,obj.HasImage];
                includeTitles = ["skills","attacks","languages","image"];
                includeVals = [string(obj.Skills),string(obj.Armaments),string(obj.Languages),string(obj.Image)   ];

                for i = 1:length(hasTitles)
                   if hasTriggers(i) 
                      text = text +  hasTitles(i) + " = 1, " + prepareText(includeTitles(i)) + " = " + prepareText(includeVals(i)) + ", ";
                   end

                end
                
                
                if mode == 2
                    s = "participants = { ";
                   for j = 1:length(participants)
                       s = s + "{" +prepareText(participants{j}) + "}";
                       if j < length(participants)
                           s = s + ", ";
                       end
                   end
                   text = text + "\n" + s + "}, \n";
                end
               text = text + "description = " + prepareText(obj.Description) + "}";
            end
        end
        
        function s = statBlock(obj)
            names = ["fit", "prs","vit","cha","dec","ins","int","wil","pcp"];
            vals = [obj.Fitness, obj.Precision, obj.Vitality, obj.Charm, obj.Deception, obj.Insight, obj.Intelligence, obj.Willpower, obj.Perception];
            
            s = "";
            for i = 1:length(names)
                
                v = vals(i);
                if isnan(v)
                    v = 0;
                end
               
                s = s + names(i) + " =" + num2str(v) + ", ";
            end
                
        end
        
        function s = ResistanceText(obj)
           s = "";
           ns = ["Immune", "Resistant", "Susceptible"];
           vs = [string(obj.Immune), string(obj.Resistant), string(obj.Susceptible)];
           
           ns2 = string.empty;
           nonZero = string.empty;
           for i = 1:length(ns)
              if (vs(i) ~= "")
                  ns2(end+1) = ns(i);
                  nonZero(end+1) = vs(i);
              end
           end
           
           if isempty(nonZero)
               s = "hasDamage = 0, ";
           else
               s = "damage =";
               
               for i = 1:length(nonZero)
                   s = s + "\key{" + ns2(i) + "} to \textit{" + nonZero(i) + "}";
                   
                   if length(nonZero) > 1
                      if i < length(nonZero) -1
                          s = s + "\comma{} ";
                      end
                      if i == length(nonZero) -1
                          s = s + " and ";
                      end
                   end
               end
               
               s = "hasDamage = 1, " + prepareText(s) + ", ";
           end
           
           
        end
        
        function obj =  parseAbilities(obj)
            MoveRatings = [obj.WalkSpeed, obj.SwimSpeed, obj.ClimbSpeed, obj.FlySpeed, obj.TunnelSpeed];
            MoveNames = ["Speed", "Swim","Climb", "Flight","Tunnelling"];
            TrueNames = ["Walking", "Swimming", "Climbing", "Flying", "Tunnelling"];
            MoveBase = [3,0,0,0,0];
            MoveMult = [1,0.5,0.5,4,0.25];
            
            
            [starts, ends] = regexp(obj.Skills,"\\skill{[^}]*}{\d*}");
            
            names = string.empty;
            ratings = [];
            f = char(obj.Skills);
            
            for i = 1:length(starts)
                [a,b] = skillExtractor(string(f(starts(i):ends(i))));
                if ~any(a == MoveNames)
                    names(end+1) = a;
                    ratings(end+1) = b;
                end
            end
            
            
            s = "\speeds{";
            for i = 1:length(MoveRatings)
               if MoveRatings(i) > 0
                  names(end+1) = MoveNames(i);
                  ratings(end+1) = MoveRatings(i);
               end
                
               speed = MoveBase(i) + MoveMult(i) * MoveRatings(i);
               if speed > 0
                   s = s + "\speedrating{" + TrueNames(i) + "}{" + num2str(speed) + "}";
               end
            end
            s = s + "}";
            obj.Movement = s;
            
            
            [newRates,I] = sort(ratings);
            newNames = names(I);
            
            newSkills = "";
            for i = length(newNames):-1:1
                newSkills = newSkills + "\\skill{" + newNames(i) + "}{" + num2str(newRates(i)) + "}\n";
            end
            obj.Skills = sprintf(newSkills);            
        end
    end
end

function [name, rating] = skillExtractor(skill)
    [~,r] = strtok(skill,'}{');
    [name,r2] = strtok(r,'}{');
    rating = str2num(strtok(r2,'}{'));
end

