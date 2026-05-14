-- This script was generated using the MoonVeil Obfuscator v1.4.5 [https://moonveil.cc]

local v,fh,cb,Y,Qb,Ci=game:GetService'Players',game:GetService'Workspace',game:GetService'UserInputService',game:GetService'RunService',game:GetService'ReplicatedStorage',game:GetService'TweenService'
local ym,Kg,Tc,Pg,xm,Dh,Ie,Vf,C,dl,Hj,Oa,fd,ma=v.LocalPlayer,nil,game:GetService'HttpService',false,nil,nil,nil,nil,nil,nil,{},{},{},{idle=nil,walking=nil,jumping=nil}
local dd=tostring(ym.UserId)
local ud='ac_reanim_'..dd
local Zf,Uf,aa,Sa=ud..'/state_animations.json',{},{heightScale=1,widthScale=1},ud..'/animation_list_cache.json';
_G.hiddenBodyParts=_G.hiddenBodyParts or{}
local El,Wd,yk,Ij,la,xg,Fg,zk,Rl,p,el_,Rf,md,vc,Ni=_G.hiddenBodyParts,{'Head','UpperTorso','LowerTorso','LeftUpperArm','LeftLowerArm','LeftHand','RightUpperArm','RightLowerArm','RightHand','LeftUpperLeg','LeftLowerLeg','LeftFoot','RightUpperLeg','RightLowerLeg','RightFoot','Torso','Left Arm','Right Arm','Left Leg','Right Leg','HumanoidRootPart'},false,1,false,{Head=Vector3 .new(101,3,-2152),UpperTorso=Vector3 .new(101,3,-2150002),LowerTorso=Vector3 .new(101,3,-2150002),Torso=Vector3 .new(101,3,-2150002),LeftUpperArm=Vector3 .new(0,3,0),LeftLowerArm=Vector3 .new(0,3,0),LeftHand=Vector3 .new(0,3,0),['Left Arm']=Vector3 .new(0,3,0),RightUpperArm=Vector3 .new(999999,3,0),RightLowerArm=Vector3 .new(0,3,0),RightHand=Vector3 .new(0,3,0),['Right Arm']=Vector3 .new(999999,3,0),LeftUpperLeg=Vector3 .new(-10000000,3,25000000),LeftLowerLeg=Vector3 .new(-10000000,3,-25000000),LeftFoot=Vector3 .new(0,3,0),['Left Leg']=Vector3 .new(-10000000,3,25000000),RightUpperLeg=Vector3 .new(10000000,3,25000000),RightLowerLeg=Vector3 .new(10000000,3,-25000000),RightFoot=Vector3 .new(0,3,0),['Right Leg']=Vector3 .new(10000000,3,25000000)},{Head=Vector3 .new(101,1003,-2152),UpperTorso=Vector3 .new(101,1015,-2150002),LowerTorso=Vector3 .new(101,996.79999999999995,-2150002),Torso=Vector3 .new(101,1015,-2150002),LeftUpperArm=Vector3 .new(0,1000,0),LeftLowerArm=Vector3 .new(0,1000,0),LeftHand=Vector3 .new(0,1000,0),['Left Arm']=Vector3 .new(0,1000,0),RightUpperArm=Vector3 .new(999999,1000,0),RightLowerArm=Vector3 .new(0,1000,0),RightHand=Vector3 .new(0,1000,0),['Right Arm']=Vector3 .new(999999,1000,0),LeftUpperLeg=Vector3 .new(-10000000,1015,25000000),LeftLowerLeg=Vector3 .new(-10000000,1015,-25000000),LeftFoot=Vector3 .new(0,1000,0),['Left Leg']=Vector3 .new(-10000000,1015,25000000),RightUpperLeg=Vector3 .new(10000000,1015,25000000),RightLowerLeg=Vector3 .new(10000000,1015,-25000000),RightFoot=Vector3 .new(0,1000,0),['Right Leg']=Vector3 .new(10000000,1015,25000000)},{},{},{},{'Head','UpperTorso','LowerTorso','LeftUpperArm','LeftLowerArm','LeftHand','RightUpperArm','RightLowerArm','RightHand','LeftUpperLeg','LeftLowerLeg','LeftFoot','RightUpperLeg','RightLowerLeg','RightFoot'},{isRunning=false,currentId=nil,keyframes=nil,totalDuration=0,elapsedTime=0,speed=1,connection=nil},{},{},false;
(function()
    local function I(Qk)
        if Kg then
            local Ym=Qk:WaitForChild('HumanoidRootPart',5)
            if Ym then
                Ym.CFrame=Kg
            end
            Kg=nil
        end
        local xk=Qk:FindFirstChildOfClass'Humanoid'
        if xk then
            xk.Died:Connect(function()
                local nd=Qk:FindFirstChild'HumanoidRootPart'
                if nd then
                    Kg=nd.CFrame
                end
            end)
        end
    end
    if ym.Character then
        I(ym.Character)
    end
    ym.CharacterAdded:Connect(I)
end)()
local me,Hi,Ue,Gi,Ng,Sg={},{},{},ud..'/custom_animations.json',ud..'/speed_keybinds.json',{}
local function Ii()
    if not isfolder(ud)then
        makefolder(ud)
    end
    if not isfolder'Drop JSON FILES HERE'then
        makefolder'Drop JSON FILES HERE'
    end
end
local function bd()
    Ii();
    pcall(function()
        local wi=listfiles'Drop JSON FILES HERE'
        for Cb,_n in ipairs(wi)do
            if _n:lower():match'%.json$'then
                local Xl,Mf=pcall(readfile,_n)
                if Xl and Mf and Mf~=''then
                    local x,uk=pcall(Tc.JSONDecode,Tc,Mf)
                    if x and type(uk)=='table'then
                        if uk[1]and type(uk[1])=='table'then
                            for ml,Sb in ipairs(uk)do
                                if Sb.name and Sb.id then
                                    local O,zd=tostring(Sb.name),tostring(Sb.id);
                                    Ue[O]=zd;
                                    md[O]=zd
                                    if not table.find(vc,O)then
                                        table.insert(vc,O)
                                    end
                                end
                            end
                        else
                            for ki,xh in pairs(uk)do
                                local jb,Am=tostring(ki),tostring(xh);
                                Ue[jb]=Am;
                                md[jb]=Am
                                if not table.find(vc,jb)then
                                    table.insert(vc,jb)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end
local function rl()
    Ii()
    local Va={animations=md,order=vc,timestamp=os.time()}
    local jn,Ne=pcall(Tc.JSONEncode,Tc,Va)
    if jn then
        pcall(function()
            writefile(Sa,Ne)
        end)
    end
end
local function ig()
    Ii()
    local gc,wm=pcall(readfile,Sa)
    if gc then
        local ia,xd=pcall(Tc.JSONDecode,Tc,wm)
        if ia and(typeof(xd)=='table'and(xd.animations and xd.order))then
            md=xd.animations;
            vc=xd.order
            return true
        end
    end
    return false
end
local function G()
    if Ni then
        return
    else
        Ni=true
        local mf,if_=pcall(game.HttpGet,game,'https://yourscoper.vercel.app/scripts/akadmin/animlist.lua',true)
        if mf then
            local rm,ob=pcall(loadstring(if_))
            if rm and type(ob)=='table'then
                md={}
                local Nh,ad,mg=pairs(ob)
                while true do
                    local q;
                    mg,q=Nh(ad,mg)
                    if mg==nil then
                        break
                    end
                    md[mg]=q
                end
                rl()
            end
        else
            return
        end
    end
end
local function Ad()
    Ii()
    local mb,Oj,Ik=pairs(me)
    local Dc={}
    while true do
        local Be;
        Ik,Be=mb(Oj,Ik)
        if Ik==nil then
            break
        end
        Dc[Ik]=tostring(Be)
    end
    local Bl,jj=pcall(Tc.JSONEncode,Tc,Dc)
    if Bl then
        pcall(function()
            writefile(ud..'/favorite_animations.json',jj)
        end)
    end
end
local function Oh()
    Ii()
    local Lh,Oi=pcall(readfile,ud..'/favorite_animations.json')
    if Lh then
        local Tg,kb=pcall(Tc.JSONDecode,Tc,Oi)
        if Tg and typeof(kb)=='table'then
            me={}
            local ha,gl,jd=pairs(kb)
            while true do
                local Cj;
                jd,Cj=ha(gl,jd)
                if jd==nil then
                    break
                end
                me[jd]=Cj
                if not md[jd]then
                    md[jd]=Cj
                    if not table.find(vc,jd)then
                        table.insert(vc,jd)
                    end
                end
            end
        else
            me={}
        end
    else
        me={}
    end
end
local function Jl()
    Ii()
    local Rd,Ol,zc=pairs(Hi)
    local cf={}
    while true do
        local li;
        zc,li=Rd(Ol,zc)
        if zc==nil then
            break
        end
        cf[zc]=li.Name
    end
    local ab,Ek=pcall(Tc.JSONEncode,Tc,cf)
    if ab then
        pcall(function()
            writefile(ud..'/animation_keybinds.json',Ek)
        end)
    end
end
local function g()
    Ii()
    local k,rj=pcall(readfile,ud..'/animation_keybinds.json')
    if k then
        local Vg,sj=pcall(Tc.JSONDecode,Tc,rj)
        if Vg and typeof(sj)=='table'then
            Hi={}
            local le,P,de=pairs(sj)
            while true do
                local al;
                de,al=le(P,de)
                if de==nil then
                    break
                end
                local Dg=Enum.KeyCode[al]
                if Dg then
                    Hi[de]=Dg
                end
            end
        else
            Hi={}
        end
    else
        Hi={}
    end
end
local function ji()
    Ii()
    local Xi={}
    for mj=1,5 do
        if Sg[mj]then
            Xi['slot'..mj]={speed=Sg[mj].speed or mj*2-1,key=Sg[mj].key or''}
        end
    end
    local dn,Uk=pcall(Tc.JSONEncode,Tc,Xi)
    if dn then
        pcall(function()
            writefile(Ng,Uk)
        end)
    end
end
local function ag()
    Ii()
    local o_,_h=pcall(readfile,Ng)
    if o_ then
        local ui,fk=pcall(Tc.JSONDecode,Tc,_h)
        if ui and typeof(fk)=='table'then
            for Qf=1,5 do
                local mm='slot'..Qf
                if fk[mm]then
                    Sg[Qf]={speed=fk[mm].speed or Qf*2-1,key=fk[mm].key or''}
                end
            end
        end
    end
end
local function Yc()
    Ii()
    local ec={idle=ma.idle,walking=ma.walking,jumping=ma.jumping}
    local im,Ye=pcall(Tc.JSONEncode,Tc,ec)
    if im then
        pcall(function()
            writefile(Zf,Ye)
        end)
    end
end
local function uc()
    Ii()
    local Gk,Gj=pcall(readfile,Zf)
    if Gk then
        local Jg,Pc=pcall(Tc.JSONDecode,Tc,Gj)
        if Jg and typeof(Pc)=='table'then
            ma.idle=Pc.idle;
            ma.walking=Pc.walking;
            ma.jumping=Pc.jumping
        end
    end
end
local function Wi()
    Ii()
    local kl,Ok,pf=pairs(Ue)
    local Xh={}
    while true do
        local Ri;
        pf,Ri=kl(Ok,pf)
        if pf==nil then
            break
        end
        Xh[pf]=Ri
    end
    local ya,Td=pcall(Tc.JSONEncode,Tc,Xh)
    if ya then
        pcall(function()
            writefile(Gi,Td)
        end)
    end
end
local function Ml()
    Ii()
    local l_,Id=pcall(readfile,Gi)
    if l_ then
        local dg,lm=pcall(Tc.JSONDecode,Tc,Id)
        if dg and typeof(lm)=='table'then
            Ue={}
            local Gf,Qd,fm=pairs(lm)
            while true do
                local Ac;
                fm,Ac=Gf(Qd,fm)
                if fm==nil then
                    break
                end
                Ue[fm]=Ac;
                md[fm]=Ac
                if not table.find(vc,fm)then
                    table.insert(vc,fm)
                end
            end
        else
            Ue={}
        end
    else
        Ue={}
    end
    bd()
end
local function Cg()
    Ii();
    ig();
    g();
    Oh();
    Ml();
    uc();
    ag();
    task.spawn(function()
        wait(2)
        if isfile(Sa)then
            pcall(function()
                delfile(Sa)
            end);
            print'Deleted old animation cache'
        end
        G();
        Ml()
    end)
end
local gk={}
local function vk()
    local Zj=ym:FindFirstChildWhichIsA'PlayerGui'
    if Zj then
        local Um,Kh,Hd=ipairs(Zj:GetChildren())
        while true do
            local Fk;
            Hd,Fk=Um(Kh,Hd)
            if Hd==nil then
                break
            end
            if Fk:IsA'ScreenGui'and Fk.ResetOnSpawn then
                table.insert(gk,Fk);
                Fk.ResetOnSpawn=false
            end
        end
    end
end
local function bl()
    local Ef,Qc,hg=ipairs(gk)
    while true do
        local Qa;
        hg,Qa=Ef(Qc,hg)
        if hg==nil then
            break
        end
        Qa.ResetOnSpawn=true
    end
    table.clear(gk)
end
local function bk()
    if Dh then
        local ka=Dh
        local ua,Il,um=pairs(ka:GetDescendants())
        while true do
            local J;
            um,J=ua(Il,um)
            if um==nil then
                break
            end
            if J:IsA'BasePart'then
                J.Transparency=1
            end
        end
        local hm=Dh:FindFirstChild'Head'
        if hm then
            local Pl,sb,Pm=ipairs(hm:GetChildren())
            while true do
                local cl;
                Pm,cl=Pl(sb,Pm)
                if Pm==nil then
                    break
                end
                if cl:IsA'Decal'then
                    cl.Transparency=1
                end
            end
        end
    end
end
local function F(Dl)
    if not(Pg and(xm and(xm.Parent and(Dh and Dh.Parent))))then
        return
    end
    if not yk then
        return
    end
    local wj=Dh:FindFirstChild'HumanoidRootPart'
    if not wj then
        return
    end
    if not Rl then
        Rl={}
    end
    if not zk then
        zk={}
    end
    if#el_==0 then
        return
    end
    local Zi=wj.AssemblyLinearVelocity.Magnitude>0.10000000000000001
    if not p then
        p={}
    end
    table.insert(p,1,{pos=wj.Position,rot=wj.CFrame-wj.Position})
    if 3000<#p then
        table.remove(p)
    end
    do
        local Ib=el_[1]
        local Sf=xm:FindFirstChild(Ib)
        if Sf then
            if not Rl[Ib]then
                Rl[Ib]=Sf.CFrame
            end
            if not zk[Ib]then
                zk[Ib]=Sf.CFrame
            end
            if Zi then
                local ie,Wg=wj.Position,wj.CFrame-wj.Position;
                Rl[Ib]=CFrame.new(ie)*Wg
            end
            local Hh=zk[Ib]:Lerp(Rl[Ib],0.10000000000000001);
            Sf.CFrame=Hh;
            Sf.AssemblyLinearVelocity=Vector3 .zero;
            Sf.AssemblyAngularVelocity=Vector3 .zero;
            zk[Ib]=Hh
            for ef=2,#el_ do
                local di=el_[ef]
                local xl,hc=xm:FindFirstChild(di),xm:FindFirstChild(el_[ef-1])
                if xl then
                    if hc then
                        if not Rl[di]then
                            Rl[di]=xl.CFrame
                        end
                        if not zk[di]then
                            zk[di]=xl.CFrame
                        end
                        if Zi then
                            local eb,Xm=hc.Position,hc.CFrame-hc.Position
                            local fi
                            if ef==2 then
                                fi=(eb-wj.Position).Unit
                            else
                                local rh=xm:FindFirstChild(el_[ef-2])
                                if rh then
                                    fi=(eb-rh.Position).Unit
                                else
                                    fi=Xm.LookVector
                                end
                            end
                            if fi.Magnitude<0.10000000000000001 then
                                fi=Xm.LookVector
                            end
                            local zf=eb+fi*Ij;
                            Rl[di]=CFrame.new(zf)*Xm
                        end
                        local Ag=zk[di]:Lerp(Rl[di],0.10000000000000001);
                        xl.CFrame=Ag;
                        xl.AssemblyLinearVelocity=Vector3 .zero;
                        xl.AssemblyAngularVelocity=Vector3 .zero;
                        zk[di]=Ag
                    end
                end
            end
        end
    end
end
local function ce(Nf)
    if Pg and(xm and(xm.Parent and(Dh and Dh.Parent)))then
        if yk then
            F(Nf)
            return
        elseif groundModeEnabled then
            local tg,xa,lh=pairs(xg)
            while true do
                local zb;
                lh,zb=tg(xa,lh)
                if lh==nil then
                    break
                end
                local Te=xm:FindFirstChild(lh)
                if Te and Te:IsA'BasePart'then
                    Te.CFrame=CFrame.new(zb);
                    Te.AssemblyLinearVelocity=Vector3 .zero;
                    Te.AssemblyAngularVelocity=Vector3 .zero
                end
            end
            return
        elseif la then
            local Pk,bi,na=pairs(Fg)
            while true do
                local lj;
                na,lj=Pk(bi,na)
                if na==nil then
                    break
                end
                local eg=xm:FindFirstChild(na)
                if eg and eg:IsA'BasePart'then
                    eg.CFrame=CFrame.new(lj);
                    eg.AssemblyLinearVelocity=Vector3 .zero;
                    eg.AssemblyAngularVelocity=Vector3 .zero
                end
            end
        else
            local Nm,ea,th_=ipairs(Wd)
            while true do
                local kg;
                th_,kg=Nm(ea,th_)
                if th_==nil then
                    break
                end
                local Ki,Qh=xm:FindFirstChild(kg),Dh:FindFirstChild(kg)
                if Ki and Qh then
                    if _G.hiddenBodyParts[kg]then
                        if not _G.hiddenBodyPartPositions then
                            _G.hiddenBodyPartPositions={}
                        end
                        if not _G.hiddenBodyPartPositions[kg]then
                            local rb,_g=Vector3 .new(0,-500,0),Ki.CFrame-Ki.Position;
                            _G.hiddenBodyPartPositions[kg]=CFrame.new(rb)*_g
                        end
                        Ki.CFrame=_G.hiddenBodyPartPositions[kg]
                    else
                        if _G.hiddenBodyPartPositions then
                            _G.hiddenBodyPartPositions[kg]=nil
                        end
                        Ki.Anchored=false;
                        Ki.CFrame=Qh.CFrame
                    end
                    Ki.AssemblyLinearVelocity=Vector3 .zero;
                    Ki.AssemblyAngularVelocity=Vector3 .zero
                end
            end
            local Mk=Dh:FindFirstChildWhichIsA'Humanoid'
            if Mk and(aa.heightScale~=1 or aa.widthScale~=1)then
                local _k=dl*aa.heightScale-0.5;
                Mk.HipHeight=math.max(_k,0.20000000000000001)
            end
        end
    else
        return
    end
end
local function Bg()
    if Pg and Dh then
        local ta=Dh:FindFirstChildWhichIsA'Humanoid'
        if ta then
            local Ce=dl*aa.heightScale-0.5;
            ta.HipHeight=math.max(Ce,0.20000000000000001)
            local ge,ll,Ji=pairs(Hj)
            while true do
                local Tk;
                Ji,Tk=ge(ll,Ji)
                if Ji==nil then
                    break
                end
                if Ji and Ji:IsA'BasePart'then
                    Ji.Size=Vector3 .new(Tk.X*aa.widthScale,Tk.Y*aa.heightScale,Tk.Z*aa.widthScale)
                end
            end
            local ln,Ll,Bm=pairs(Oa)
            while true do
                local bg;
                Bm,bg=ln(Ll,Bm)
                if Bm==nil then
                    break
                end
                if Bm and Bm:IsA'Motor6D'then
                    local sa=bg.C0 .Position
                    local Df=Vector3 .new(sa.X*aa.widthScale,sa.Y*aa.heightScale,sa.Z*aa.widthScale);
                    Bm.C0=CFrame.new(Df)*(bg.C0-bg.C0 .Position)
                    local fl=bg.C1 .Position
                    local Aa=Vector3 .new(fl.X*aa.widthScale,fl.Y*aa.heightScale,fl.Z*aa.widthScale);
                    Bm.C1=CFrame.new(Aa)*(bg.C1-bg.C1 .Position)
                end
            end
        end
    else
        return
    end
end
local function Xb()
    pcall(function()
        local Ak=fh:FindFirstChild'VirtuallyNad'
        if Ak then
            local Jb=Ak:FindFirstChild'HeadMovement'
            if Jb and Jb:IsA'LocalScript'then
                Jb.Disabled=true
            end
        end
        ym:SetAttribute('TurnHead',false)
    end)
end
local function Md()
    pcall(function()
        local Sm=fh:FindFirstChild'VirtuallyNad'
        if Sm then
            local Kj=Sm:FindFirstChild'HeadMovement'
            if Kj and Kj:IsA'LocalScript'then
                Kj.Disabled=false
            end
        end
    end)
end
local Og,gm=nil,false
local function Nk(tk)
    if gm then
        return
    end
    gm=true
    local h,Vd,zh={'click_the_player','input','map','picture_to_avatar','vr'},ym:FindFirstChildWhichIsA'PlayerGui',game:GetService'ReplicatedStorage':FindFirstChild'Storage'or game:GetService'ReplicatedStorage'
    if Vd then
        for ed,Gg in ipairs(Vd:GetChildren())do
            if Gg:IsA'Folder'and table.find(h,Gg.Name)then
                if not zh:FindFirstChild(Gg.Name)then
                    local yd=Gg:Clone();
                    yd.Parent=zh
                end
            end
        end
    end
    Y.Heartbeat:Connect(function()
        if not Vd then
            return
        end
        for Af,Gd in ipairs(zh:GetChildren())do
            if Gd:IsA'Folder'and table.find(h,Gd.Name)then
                if not Vd:FindFirstChild(Gd.Name)then
                    local dc=Gd:Clone();
                    dc.Parent=Vd
                end
            end
        end
    end);
    Pg=tk
    local Gm,ai,Ai,Wj=game:GetService'ReplicatedStorage':FindFirstChild'event_rag',game:GetService'ReplicatedStorage':FindFirstChild'Ragdoll',game:GetService'ReplicatedStorage':FindFirstChild'Unragdoll',nil
    if not(Gm or ai)then
        local ja,_i=pcall(function()
            local ok=Qb:FindFirstChild('LocalModules',true)
            local gn=ok and ok:FindFirstChild'Backend'
            if gn then
                local N,qa=require,gn.FindFirstChild
            end
        end);
        Wj=ja and _i and _i or Wj
    end
    if Pg then
        local in_=ym.Character
        if not in_ then
            return
        end
        local yb,_a=in_:FindFirstChildOfClass'Humanoid',in_:FindFirstChild'HumanoidRootPart'
        if not(yb and _a)then
            return
        end
        xm=in_;
        Ie=_a.CFrame;
        in_.Archivable=true;
        Dh=in_:Clone();
        in_.Archivable=false
        local Ja=xm.Name;
        Dh.Name=Ja..'Celeste'
        local bh=Dh:FindFirstChildWhichIsA'Humanoid'
        if bh then
            bh.DisplayName=Ja..'Celeste';
            dl=bh.HipHeight;
            aa={heightScale=1,widthScale=1};
            bh.WalkSpeed=yb.WalkSpeed;
            bh.JumpPower=yb.JumpPower
        end
        local Wb=not Dh.PrimaryPart and Dh:FindFirstChild'HumanoidRootPart'
        if Wb then
            Dh.PrimaryPart=Wb
        end
        bk();
        Hj={};
        Oa={}
        local Mg=Dh
        local sd,pe,s_=ipairs(Mg:GetDescendants())
        while true do
            local hi;
            s_,hi=sd(pe,s_)
            if s_==nil then
                break
            end
            if hi:IsA'BasePart'then
                Hj[hi]=hi.Size
            elseif hi:IsA'Motor6D'then
                Oa[hi]={C0=hi.C0,C1=hi.C1}
            end
        end
        local Wh=xm:FindFirstChild'Animate'
        if Wh then
            Vf=Wh:Clone();
            Vf.Parent=Dh;
            Vf.Disabled=true
        end
        vk();
        Dh.Parent=fh;
        ym.Character=Dh
        if bh then
            fh.CurrentCamera.CameraSubject=bh
        end
        bl()
        if Vf then
            Vf.Disabled=false
        end
        if bh then
            bh:ChangeState(Enum.HumanoidStateType.Running)
        end
        task.spawn(function()
            if Pg then
                if Gm then
                    pcall(function()
                        local nb=game:GetService'ReplicatedStorage':FindFirstChild'event_rag'
                        if nb then
                            local jm=xm and(xm:FindFirstChildOfClass'Humanoid'and xm:FindFirstChildOfClass'Humanoid')
                            if jm then
                                game.Players.LocalPlayer.Character.Humanoid.HipHeight=jm.HipHeight
                            end
                            nb:FireServer(unpack{'Hinge'})
                        end
                    end)
                elseif ai then
                    pcall(function()
                        local tj=game:GetService'ReplicatedStorage':FindFirstChild'Ragdoll'
                        if tj then
                            tj:FireServer(unpack{'Ball'})
                        end
                    end)
                elseif Wj then
                    pcall(function()
                        Wj.Ragdoll:Fire(true);
                        Xb()
                    end)
                end
                if C then
                    C:Disconnect()
                end
                C=Y.Heartbeat:Connect(ce);
                gm=false
            end
        end)
    else
        local A,Ql,Vj=pairs(Uf)
        while true do
            local ee;
            Vj,ee=A(Ql,Vj)
            if Vj==nil then
                break
            end
            if ee then
                ee:Disconnect()
            end
        end
        Uf={}
        if C then
            C:Disconnect();
            C=nil
        end
        if Rf.connection then
            Rf.connection:Disconnect();
            Rf.connection=nil
        end
        Rf.isRunning=false
        if not(xm and Dh)then
            return
        end
        for Ze=1,3 do
            pcall(function()
                if Gm then
                    local b_=game:GetService'ReplicatedStorage':FindFirstChild'event_rag'
                    if b_ then
                        b_:FireServer(unpack{'Hinge'})
                    end
                elseif Ai then
                    local f_=game:GetService'ReplicatedStorage':FindFirstChild'Unragdoll'
                    if f_ then
                        f_:FireServer()
                    end
                elseif Wj then
                    Wj.Ragdoll:Fire(false);
                    Md()
                end
            end);
            task.wait(0.10000000000000001)
        end
        local wa,vh=xm:FindFirstChild'HumanoidRootPart',Dh:FindFirstChild'HumanoidRootPart'
        local Nl,gh=vh and vh.CFrame or Ie,Dh:FindFirstChild'Animate'
        if gh then
            gh.Parent=xm;
            gh.Disabled=true
        end
        Dh:Destroy()
        if wa then
            wa.CFrame=Nl
        end
        local Gc=xm:FindFirstChildWhichIsA'Humanoid';
        vk();
        ym.Character=xm
        if Gc then
            fh.CurrentCamera.CameraSubject=Gc
        end
        bl()
        if gh then
            task.wait(0.10000000000000001);
            gh.Disabled=false
        end
        Og=nil;
        gm=false
    end
    gm=false
end
local Hk={}
local function L()
    Rf.isRunning=false
    if Dh then
        local ol,Ed,Sh=pairs(Oa)
        while true do
            local qe;
            Sh,qe=ol(Ed,Sh)
            if Sh==nil then
                break
            end
            if Sh and Sh:IsA'Motor6D'then
                Sh.C0=qe.C0
            end
        end
        local cj=Dh
        local Cf,hf,Re=pairs(cj:GetChildren())
        while true do
            local db;
            Re,db=Cf(hf,Re)
            if Re==nil then
                break
            end
            if db:IsA'LocalScript'and(not db.Enabled and db~=Vf)then
                db.Enabled=true
            end
        end
        if Vf then
            Vf.Disabled=false
        end
    end
    if Rf.connection then
        Rf.connection:Disconnect();
        Rf.connection=nil
    end
    local kk,mn,Pe=pairs(Hk)
    while true do
        local gf;
        Pe,gf=kk(mn,Pe)
        if Pe==nil then
            break
        end
        gf.NameButton.BackgroundColor3=Color3 .fromRGB(15,15,20)
    end
end
local function Ka(ni_)
    if not Dh then
        warn'Reanimate first!'
        return
    end
    if ni_==''then
        return
    end
    local bm=Dh:FindFirstChildWhichIsA'Humanoid'
    if not bm then
        return
    end
    local Pj=Dh:FindFirstChild'LowerTorso'~=nil
    if not(Pj and Dh:FindFirstChild'LowerTorso'or Dh:FindFirstChild'Torso')then
        return
    end
    if Rf.isRunning and Rf.currentId==ni_ then
        L();
        Rf.currentId=nil
        return
    end
    local vj,Uh,Zb=pairs(Hk)
    while true do
        local ri;
        Zb,ri=vj(Uh,Zb)
        if Zb==nil then
            break
        end
        ri.NameButton.BackgroundColor3=Color3 .fromRGB(15,15,20)
    end
    local ic={md,me}
    local Wc,ak,Rg=pairs(ic)
    local jh=nil
    while true do
        local em;
        Rg,em=Wc(ak,Rg)
        if Rg==nil then
            v320=jh
        end
        local Pd,ej,Dk=pairs(em)
        while true do
            local wc;
            Dk,wc=Pd(ej,Dk)
            if Dk==nil then
                Dk=jh
                break
            end
            if tostring(wc)==ni_ then
                break
            end
        end
        if Dk then
            break
        end
        jh=Dk
    end
    if v320 and Hk[v320]then
        Hk[v320].NameButton.BackgroundColor3=Color3 .fromRGB(160,160,175)
    end
    if Vf and(bm.MoveDirection.Magnitude>0 or bm:GetState()==Enum.HumanoidStateType.Running)then
        Vf.Disabled=true
        local gj,oe,Nb=pairs(bm:GetPlayingAnimationTracks())
        while true do
            local ld;
            Nb,ld=gj(oe,Nb)
            if Nb==nil then
                break
            end
            ld:Stop()
        end
    end
    local Em=fd[ni_]
    if not Em then
        local xf=nil
        if tostring(ni_):match'^http'then
            local dk,Ub=pcall(function()
                return game:HttpGet(ni_)
            end)
            if dk then
                local yc;
                yc,Em=pcall(function()
                    return loadstring(Ub)()
                end)
                if yc and type(Em)=='table'then
                    xf=true
                else
                    Em=nil
                end
            else
                Em=nil
            end
        elseif tonumber(ni_)then
            if fd[ni_]then
                xf=true;
                Em=fd[ni_]
            else
                task.spawn(function()
                    local hn,df=pcall(function()
                        return game:GetObjects('rbxassetid://'..ni_)[1]
                    end)
                    if hn and df then
                        fd[ni_]=df
                    end
                end);
                xf,Em=pcall(function()
                    return game:GetObjects('rbxassetid://'..ni_)[1]
                end)
            end
        else
            local yi;
            yi,Em=pcall(function()
                return loadstring(ni_)()
            end)
            if yi and type(Em)=='table'then
                xf=true
            else
                Em=nil
            end
        end
        if not(xf and Em)then
            return
        end
        fd[ni_]=Em
    end
    if type(Em)~='table'then
        Em.Priority=Enum.AnimationPriority.Action;
        Rf.keyframes=Em:GetKeyframes()
        if not Rf.keyframes or#Rf.keyframes==0 then
            return
        end
        Rf.totalDuration=Rf.keyframes[#Rf.keyframes].Time
    else
        local kf=next(Em)
        if not kf then
            return
        end
        Rf.keyframes=Em[kf]
        if not Rf.keyframes or#Rf.keyframes==0 then
            return
        end
        Rf.totalDuration=Rf.keyframes[#Rf.keyframes].Time
    end
    Rf.currentId=ni_;
    Rf.elapsedTime=0;
    Rf.isRunning=true
    local Zc=Dh
    local Cm
    if Pj then
        local Fm,i_,ul,La,Kl,ff,lc,_d,gd,Fe,wd,Le,Gl,te,nh,ik=Zc:FindFirstChild'HumanoidRootPart',Zc:FindFirstChild'Head',Zc:FindFirstChild'LeftUpperArm',Zc:FindFirstChild'RightUpperArm',Zc:FindFirstChild'LeftUpperLeg',Zc:FindFirstChild'RightUpperLeg',Zc:FindFirstChild'LeftFoot',Zc:FindFirstChild'RightFoot',Zc:FindFirstChild'LeftHand',Zc:FindFirstChild'RightHand',Zc:FindFirstChild'LeftLowerArm',Zc:FindFirstChild'RightLowerArm',Zc:FindFirstChild'LeftLowerLeg',Zc:FindFirstChild'RightLowerLeg',Zc:FindFirstChild'LowerTorso',Zc:FindFirstChild'UpperTorso';
        Cm={}
        if Fm then
            Fm=Fm:FindFirstChild'RootJoint'
        end
        Cm.Torso=Fm
        if i_ then
            i_=i_:FindFirstChild'Neck'
        end
        Cm.Head=i_
        if ul then
            ul=ul:FindFirstChild'LeftShoulder'
        end
        Cm.LeftUpperArm=ul
        if La then
            La=La:FindFirstChild'RightShoulder'
        end
        Cm.RightUpperArm=La
        if Kl then
            Kl=Kl:FindFirstChild'LeftHip'
        end
        Cm.LeftUpperLeg=Kl
        if ff then
            ff=ff:FindFirstChild'RightHip'
        end
        Cm.RightUpperLeg=ff
        if lc then
            lc=lc:FindFirstChild'LeftAnkle'
        end
        Cm.LeftFoot=lc
        if _d then
            _d=_d:FindFirstChild'RightAnkle'
        end
        Cm.RightFoot=_d
        if gd then
            gd=gd:FindFirstChild'LeftWrist'
        end
        Cm.LeftHand=gd
        if Fe then
            Fe=Fe:FindFirstChild'RightWrist'
        end
        Cm.RightHand=Fe
        if wd then
            wd=wd:FindFirstChild'LeftElbow'
        end
        Cm.LeftLowerArm=wd
        if Le then
            Le=Le:FindFirstChild'RightElbow'
        end
        Cm.RightLowerArm=Le
        if Gl then
            Gl=Gl:FindFirstChild'LeftKnee'
        end
        Cm.LeftLowerLeg=Gl
        if te then
            te=te:FindFirstChild'RightKnee'
        end
        Cm.RightLowerLeg=te
        if nh then
            nh=nh:FindFirstChild'Root'
        end
        Cm.LowerTorso=nh
        if ik then
            ik=ik:FindFirstChild'Waist'
        end
        Cm.UpperTorso=ik
    else
        Cm=(function(Uc)
            local Bh,T,kd=pairs(Uc:GetChildren())
            local pj={}
            while true do
                local an_;
                kd,an_=Bh(T,kd)
                if kd==nil then
                    break
                end
                if an_:IsA'BasePart'then
                    local Zg,Je,Nj=pairs(an_:GetChildren())
                    while true do
                        local Li;
                        Nj,Li=Zg(Je,Nj)
                        if Nj==nil then
                            break
                        end
                        if Li:IsA'Motor6D'and(Li.Part1 and Li.Part1 .Parent==Uc)then
                            local Da=Li.Part1 .Name;
                            pj[Da]=Li
                            if Da=='Left Arm'then
                                pj.LeftArm=Li
                            elseif Da=='Right Arm'then
                                pj.RightArm=Li
                            elseif Da=='Left Leg'then
                                pj.LeftLeg=Li
                            elseif Da=='Right Leg'then
                                pj.RightLeg=Li
                            elseif Da=='Head'then
                                pj.Head=Li
                            elseif Da=='HumanoidRootPart'then
                                pj.Torso=Li
                            end
                        end
                    end
                end
            end
            return pj
        end)(Zc)
    end
    local Yd={}
    if not Oa then
        Oa={}
    end
    local Qm,qg,Di=pairs(Cm)
    while true do
        local om;
        Di,om=Qm(qg,Di)
        if Di==nil then
            break
        end
        if om and om:IsA'Motor6D'then
            Yd[Di]=om
            if not Oa[om]then
                Oa[om]={C0=om.C0,C1=om.C1}
            end
        end
    end
    if not Rf.connection then
        local Ui=Dh
        local rc,Xe,bf=pairs(Ui:GetChildren())
        while true do
            local B;
            bf,B=rc(Xe,bf)
            if bf==nil then
                break
            end
            if B:IsA'LocalScript'and(B.Enabled and B~=Vf)then
                B.Enabled=false
            end
        end
        Rf.connection=Y.Heartbeat:Connect(function(ve)
            if not(Rf.isRunning and Dh)then
                L()
                return
            end
            if not Rf.keyframes then
                return
            end
            Rf.elapsedTime=Rf.elapsedTime+ve*Rf.speed
            if Rf.totalDuration>0 then
                Rf.elapsedTime=Rf.elapsedTime%Rf.totalDuration
            end
            local ga,se_=nil,nil
            for pl=1,#Rf.keyframes-1 do
                if Rf.elapsedTime>=Rf.keyframes[pl].Time then
                    if Rf.elapsedTime<Rf.keyframes[pl+1].Time then
                        ga=Rf.keyframes[pl];
                        se_=Rf.keyframes[pl+1]
                        break
                    end
                end
            end
            if not ga then
                ga=Rf.keyframes[#Rf.keyframes];
                se_=Rf.keyframes[1]
            end
            local Rb=se_.Time-ga.Time
            if Rb<=0 then
                Rb=Rf.totalDuration
            end
            local Ca=Rf.elapsedTime-ga.Time
            local D=0<Rb and Ca/Rb or 0
            local Pb=math.clamp(D,0,1)
            if ga.Data then
                local wf,z,sm=pairs(ga.Data)
                while true do
                    local ci;
                    sm,ci=wf(z,sm)
                    if sm==nil then
                        break
                    end
                    local Q=Yd[sm]
                    if Q and(Oa and Oa[Q])then
                        local Fb,cc=Oa[Q].C0*ci,se_.Data
                        if cc then
                            cc=se_.Data[sm]
                        end
                        if cc then
                            Q.C0=Fb:Lerp(Oa[Q].C0*cc,Pb)
                        else
                            Q.C0=Fb
                        end
                    end
                end
            else
                local Xg,Xk,xj=pairs(ga:GetDescendants())
                while true do
                    local zl;
                    xj,zl=Xg(Xk,xj)
                    if xj==nil then
                        break
                    end
                    if zl:IsA'Pose'then
                        local jl=Yd[zl.Name]
                        if jl and(Oa and Oa[jl])then
                            local Ia,e_=Oa[jl].C0*zl.CFrame,se_:FindFirstChild(zl.Name,true)
                            if e_ and e_:IsA'Pose'then
                                jl.C0=Ia:Lerp(Oa[jl].C0*e_.CFrame,Pb)
                            else
                                jl.C0=Ia
                            end
                        end
                    end
                end
            end
            if aa.heightScale~=1 or aa.widthScale~=1 then
                local Om,zg,lg=pairs(Oa)
                while true do
                    local _m;
                    lg,_m=Om(zg,lg)
                    if lg==nil then
                        break
                    end
                    if lg and lg:IsA'Motor6D'then
                        local hk,af=lg.C0-lg.C0 .Position,_m.C0 .Position
                        local sk=Vector3 .new(af.X*aa.widthScale,af.Y*aa.heightScale,af.Z*aa.widthScale);
                        lg.C0=CFrame.new(sk)*hk
                    end
                end
            end
        end)
    end
end
local function aj(Rk)
    if not(Dh and Pg)then
        return
    end
    local lb,sc=ma[Rk],false
    if Rf.isRunning and Rf.currentId then
        local Fl,Rm,dh=pairs(ma)
        while true do
            local Aj;
            dh,Aj=Fl(Rm,dh)
            if dh==nil then
                break
            end
            if Aj and(Aj~=''and tostring(Aj)==tostring(Rf.currentId))then
                sc=true
                break
            end
        end
    end
    if lb and lb~=''then
        if Dh then
            if Dh:FindFirstChildWhichIsA'Humanoid'then
                if Rf.isRunning and Rf.currentId then
                    if not sc then
                        return
                    end
                    if tostring(Rf.currentId)==tostring(lb)then
                        return
                    end
                end
                if Rf.isRunning then
                    L();
                    task.wait(0.050000000000000003)
                end
                if Dh and Pg then
                    pcall(function()
                        Ka(tostring(lb))
                    end)
                end
            else
                return
            end
        else
            return
        end
    else
        if sc then
            L()
        end
        return
    end
end
local function Dm()
    if not(Dh and Pg)then
        return
    end
    if not Dh:FindFirstChildWhichIsA'Humanoid'then
        return
    end
    local Hl,pg,gg=pairs(Uf)
    while true do
        local Zh,Hg=Hl(pg,gg)
        if Zh==nil then
            break
        end
        gg=Zh
        if Hg then
            pcall(function()
                Hg:Disconnect()
            end)
        end
    end
    Uf={}
    if Rf.isRunning and Rf.currentId then
        local Wk,Ih,gb=pairs(ma)
        while true do
            local il;
            gb,il=Wk(Ih,gb)
            if gb==nil then
                break
            end
            if il and(il~=''and tostring(il)==tostring(Rf.currentId))then
                L()
                break
            end
        end
    end
    local function Ej()
        if not Dh then
            return'idle'
        end
        local Sd=Dh:FindFirstChildWhichIsA'Humanoid'
        if not Sd then
            return'idle'
        end
        local Ba=Sd.MoveDirection.Magnitude
        local dj,ek=pcall(function()
            return Sd:GetState()
        end)
        return dj and((ek==Enum.HumanoidStateType.Jumping or ek==Enum.HumanoidStateType.Freefall)and'jumping'or(0.10000000000000001<Ba and'walking'or'idle'))or'idle'
    end
    local wl=Ej()
    local qf,Tf=wl,wl
    if ma[wl]and ma[wl]~=''then
        task.defer(function()
            if Dh and Pg then
                aj(wl)
            end
        end)
    end
    Uf.stateMonitor=Y.Heartbeat:Connect(function(Im)
        if not(Dh and Pg)then
            if Uf.stateMonitor then
                pcall(function()
                    Uf.stateMonitor:Disconnect()
                end);
                Uf.stateMonitor=nil
            end
            return
        end
        if not Dh:FindFirstChildWhichIsA'Humanoid'then
            if Uf.stateMonitor then
                pcall(function()
                    Uf.stateMonitor:Disconnect()
                end);
                Uf.stateMonitor=nil
            end
            return
        end
        local De=Ej()
        if De~=Tf then
            Tf=De
            local ae=false
            if Rf.isRunning and Rf.currentId then
                local en_,Yb,sh=pairs(ma)
                while true do
                    local Yl;
                    sh,Yl=en_(Yb,sh)
                    if sh==nil then
                        break
                    end
                    if Yl and(Yl~=''and tostring(Yl)==tostring(Rf.currentId))then
                        ae=true
                        break
                    end
                end
            end
            if ae then
                L()
            end
            if ma[De]and(ma[De]~=''and(Dh and Pg))then
                task.defer(function()
                    if Dh and Pg then
                        aj(De)
                    end
                end)
            end
        end
        qf=De
        if(aa.heightScale~=1 or aa.widthScale~=1)and Oa then
            local Rc,yj,re_=pairs(Oa)
            while true do
                local Xd;
                re_,Xd=Rc(yj,re_)
                if re_==nil then
                    break
                end
                if re_ and(re_:IsA'Motor6D'and re_.Parent)then
                    local Ck,Cc=re_.C0-re_.C0 .Position,Xd.C0 .Position
                    local Jj=Vector3 .new(Cc.X*aa.widthScale,Cc.Y*aa.heightScale,Cc.Z*aa.widthScale);
                    re_.C0=CFrame.new(Jj)*Ck
                end
            end
        end
    end)
end
local function Ud()
    local He,Hm,nc={panelBg=Color3 .fromRGB(0,0,0),panelBg2=Color3 .fromRGB(0,0,0),rowBg=Color3 .fromRGB(28,28,30),rowBgHover=Color3 .fromRGB(50,50,55),tabActive=Color3 .fromRGB(50,50,55),tabIdle=Color3 .fromRGB(22,22,24),inputBg=Color3 .fromRGB(18,18,20),toggleOff=Color3 .fromRGB(50,52,65),accentPlay=Color3 .fromRGB(200,210,235),btnBg=Color3 .fromRGB(28,28,30),textPrimary=Color3 .fromRGB(235,238,248),textSecond=Color3 .fromRGB(180,185,205),textDim=Color3 .fromRGB(115,120,140),textGold=Color3 .fromRGB(255,215,80),textRed=Color3 .fromRGB(240,80,80),textGreen=Color3 .fromRGB(100,220,130),textYellow=Color3 .fromRGB(240,210,80),scrollbar=Color3 .fromRGB(145,150,170),toggleOn=Color3 .fromRGB(145,160,210),knobOff=Color3 .fromRGB(105,110,130),knobOn=Color3 .fromRGB(235,240,255),stroke=Color3 .fromRGB(70,75,95),strokeBright=Color3 .fromRGB(120,128,155)},{panel=0,panel2=0,row=0,rowH=0,tab=0,tabA=0,input=0,btn=0,btnH=0.20000000000000001,overlay=0},ym:WaitForChild'PlayerGui'
    if not nc:FindFirstChild'AKReanimGUI'then
        local _f=Instance.new'ScreenGui';
        _f.Name='AKReanimGUI';
        _f.ResetOnSpawn=false;
        _f.Parent=nc
        local sg=Instance.new'Frame';
        sg.Size=UDim2 .new(0,315,0,480);
        sg.Position=UDim2 .new(1,-330,0,20);
        sg.BackgroundColor3=He.panelBg;
        sg.BackgroundTransparency=Hm.panel;
        sg.BorderSizePixel=0;
        sg.Parent=_f
        local jg=Instance.new'UIStroke';
        jg.Color=Color3 .fromRGB(160,168,200);
        jg.Thickness=1;
        jg.Transparency=0;
        jg.Parent=sg
        local Ug=Instance.new'UICorner';
        Ug.CornerRadius=UDim.new(0,12);
        Ug.Parent=sg
        local hh=Instance.new'Frame';
        hh.Size=UDim2 .new(1,0,0,30);
        hh.Position=UDim2 .new(0,0,0,0);
        hh.BackgroundColor3=He.panelBg2;
        hh.BackgroundTransparency=Hm.panel2;
        hh.BorderSizePixel=0;
        hh.Parent=sg
        local H=Instance.new'UIStroke';
        H.Color=He.stroke;
        H.Thickness=1;
        H.Transparency=0.40000000000000002;
        H.Parent=hh
        local Ig=Instance.new'UICorner';
        Ig.CornerRadius=UDim.new(0,12);
        Ig.Parent=hh
        local oc=Instance.new'TextLabel';
        oc.Size=UDim2 .new(1,-110,1,0);
        oc.Position=UDim2 .new(0,52,0,0);
        oc.BackgroundTransparency=1;
        oc.Text='AC REANIM';
        oc.TextColor3=He.textPrimary;
        oc.TextSize=16;
        oc.Font=Enum.Font.GothamBlack;
        oc.TextXAlignment=Enum.TextXAlignment.Center;
        oc.Parent=hh
        local Bk=Instance.new'TextLabel';
        Bk.Size=UDim2 .new(0,80,0,14);
        Bk.Position=UDim2 .new(0,52,0.5,4);
        Bk.BackgroundTransparency=1;
        Bk.Text='ID: '..dd;
        Bk.TextColor3=He.textDim;
        Bk.TextSize=8;
        Bk.Font=Enum.Font.Gotham;
        Bk.TextXAlignment=Enum.TextXAlignment.Center;
        Bk.Parent=hh
        local Jf=Instance.new'TextButton';
        Jf.Size=UDim2 .new(0,65,0,24);
        Jf.Position=UDim2 .new(0,6,0,3);
        Jf.BackgroundColor3=Color3 .fromRGB(0,0,0);
        Jf.BackgroundTransparency=0;
        Jf.BorderSizePixel=0;
        Jf.Text='OFF';
        Jf.TextColor3=He.textPrimary;
        Jf.TextSize=13;
        Jf.Font=Enum.Font.GothamBold;
        Jf.Parent=hh
        local Ge=Instance.new'UICorner';
        Ge.CornerRadius=UDim.new(0,7);
        Ge.Parent=Jf
        local Lj=Instance.new'UIStroke';
        Lj.Color=Color3 .fromRGB(120,128,155);
        Lj.Thickness=1;
        Lj.Parent=Jf
        local Bi=Instance.new'Frame';
        Bi.Size=UDim2 .new(0,0,0,0);
        Bi.BackgroundTransparency=1;
        Bi.Parent=Jf
        local Lb=false;
        Jf.MouseButton1Click:Connect(function()
            if gm then
                return
            end
            Lb=not Lb
            if Lb then
                Jf.Text='ON';
                Jf.BackgroundColor3=Color3 .fromRGB(145,160,210)
            else
                Jf.Text='OFF';
                Jf.BackgroundColor3=Color3 .fromRGB(0,0,0)
            end
            task.defer(function()
                Nk(Lb)
                if Lb then
                    task.spawn(function()
                        task.wait(0.29999999999999999)
                        if Pg and Dh then
                            Dm()
                        end
                    end)
                end
            end)
        end)
        local Ya=Instance.new'TextButton';
        Ya.Size=UDim2 .new(0,22,0,22);
        Ya.Position=UDim2 .new(1,-48,0,4);
        Ya.BackgroundColor3=He.btnBg;
        Ya.BackgroundTransparency=Hm.btn;
        Ya.Text='-';
        Ya.TextColor3=He.textPrimary;
        Ya.TextScaled=true;
        Ya.Font=Enum.Font.GothamBlack;
        Ya.BorderSizePixel=0;
        Ya.Parent=hh
        local Pi=Instance.new'UICorner';
        Pi.CornerRadius=UDim.new(0,7);
        Pi.Parent=Ya
        local nk=Instance.new'TextButton';
        nk.Size=UDim2 .new(0,22,0,22);
        nk.Position=UDim2 .new(1,-24,0,4);
        nk.BackgroundColor3=He.btnBg;
        nk.BackgroundTransparency=Hm.btn;
        nk.Text='X';
        nk.TextColor3=He.textPrimary;
        nk.TextScaled=true;
        nk.Font=Enum.Font.Gotham;
        nk.BorderSizePixel=0;
        nk.Parent=hh
        local uf=Instance.new'UICorner';
        uf.CornerRadius=UDim.new(0,7);
        uf.Parent=nk
        local vd=Instance.new'TextLabel';
        vd.Size=UDim2 .new(1,-16,0,12);
        vd.Position=UDim2 .new(0,8,0,32);
        vd.BackgroundTransparency=1;
        vd.Text='Ready | '..ud;
        vd.TextColor3=He.textDim;
        vd.TextSize=10;
        vd.Font=Enum.Font.GothamSemibold;
        vd.Parent=sg
        local Sk=Instance.new'Frame';
        Sk.Size=UDim2 .new(1,-16,0,24);
        Sk.Position=UDim2 .new(0,8,0,47);
        Sk.BackgroundTransparency=1;
        Sk.Parent=sg
        local nf,V,Hc={'All','Favs','Custom','States','Size','Others'},{'all','favorites','custom','states','size','others'},{}
        local ei=1/#nf
        for Fa,og in ipairs(nf)do
            local Ra=Instance.new'TextButton';
            Ra.Size=UDim2 .new(ei,-2,1,0);
            Ra.Position=UDim2 .new((Fa-1)*ei,(Fa==1 and 0 or 2),0,0);
            Ra.BackgroundColor3=Fa==1 and He.tabActive or He.tabIdle;
            Ra.BackgroundTransparency=Fa==1 and Hm.tabA or Hm.tab;
            Ra.Text=og;
            Ra.TextColor3=Fa==1 and He.textPrimary or He.textSecond;
            Ra.TextSize=11;
            Ra.Font=Enum.Font.GothamBold;
            Ra.BorderSizePixel=0;
            Ra.Parent=Sk
            local Db=Instance.new'UICorner';
            Db.CornerRadius=UDim.new(0,7);
            Db.Parent=Ra;
            Hc[V[Fa]]=Ra
        end
        local ql=Instance.new'TextBox';
        ql.Size=UDim2 .new(1,-16,0,22);
        ql.Position=UDim2 .new(0,8,0,76);
        ql.BackgroundColor3=He.inputBg;
        ql.BackgroundTransparency=Hm.input;
        ql.Text='';
        ql.PlaceholderText='Search...';
        ql.TextColor3=He.textPrimary;
        ql.PlaceholderColor3=He.textDim;
        ql.TextSize=12;
        ql.Font=Enum.Font.GothamSemibold;
        ql.BorderSizePixel=0;
        ql.Parent=sg
        local Kd=Instance.new'UIStroke';
        Kd.Color=Color3 .fromRGB(90,96,120);
        Kd.Thickness=1;
        Kd.Transparency=0;
        Kd.Parent=ql
        local Xj=Instance.new'UICorner';
        Xj.CornerRadius=UDim.new(0,8);
        Xj.Parent=ql
        local Fj=Instance.new'ScrollingFrame';
        Fj.Size=UDim2 .new(1,-16,1,-175);
        Fj.Position=UDim2 .new(0,8,0,104);
        Fj.BackgroundTransparency=1;
        Fj.ScrollBarThickness=3;
        Fj.ScrollBarImageColor3=He.scrollbar;
        Fj.ScrollBarImageTransparency=0.29999999999999999;
        Fj.BorderSizePixel=0;
        Fj.ScrollingDirection=Enum.ScrollingDirection.Y;
        Fj.Parent=sg
        local Jm=Instance.new'UIListLayout';
        Jm.Padding=UDim.new(0,3);
        Jm.SortOrder=Enum.SortOrder.LayoutOrder;
        Jm.Parent=Fj
        local kn=Instance.new'Frame';
        kn.Size=UDim2 .new(1,-16,0,80);
        kn.Position=UDim2 .new(0,8,0,104);
        kn.BackgroundTransparency=1;
        kn.Visible=false;
        kn.Parent=sg
        local dm=Instance.new'TextBox';
        dm.Size=UDim2 .new(1,0,0,22);
        dm.Position=UDim2 .new(0,0,0,0);
        dm.BackgroundColor3=He.inputBg;
        dm.BackgroundTransparency=Hm.input;
        dm.Text='';
        dm.PlaceholderText='Animation Name...';
        dm.TextColor3=He.textPrimary;
        dm.PlaceholderColor3=He.textDim;
        dm.TextSize=11;
        dm.Font=Enum.Font.Gotham;
        dm.BorderSizePixel=0;
        dm.Parent=kn
        local We=Instance.new'UICorner';
        We.CornerRadius=UDim.new(0,8);
        We.Parent=dm
        local kj=Instance.new'TextBox';
        kj.Size=UDim2 .new(1,0,0,45);
        kj.Position=UDim2 .new(0,0,0,27);
        kj.BackgroundColor3=He.inputBg;
        kj.BackgroundTransparency=Hm.input;
        kj.Text='';
        kj.PlaceholderText='Keyframe Code or Asset ID...';
        kj.TextColor3=He.textPrimary;
        kj.PlaceholderColor3=He.textDim;
        kj.TextSize=9;
        kj.Font=Enum.Font.Code;
        kj.TextWrapped=true;
        kj.TextXAlignment=Enum.TextXAlignment.Left;
        kj.TextYAlignment=Enum.TextYAlignment.Top;
        kj.ClearTextOnFocus=false;
        kj.MultiLine=true;
        kj.BorderSizePixel=0;
        kj.Parent=kn
        local Vb=Instance.new'UICorner';
        Vb.CornerRadius=UDim.new(0,8);
        Vb.Parent=kj
        local Pa=Instance.new'Frame';
        Pa.Size=UDim2 .new(1,-16,1,-175);
        Pa.Position=UDim2 .new(0,8,0,104);
        Pa.BackgroundTransparency=1;
        Pa.Visible=false;
        Pa.Parent=sg
        local tb=Instance.new'ScrollingFrame';
        tb.Size=UDim2 .new(1,0,1,0);
        tb.Position=UDim2 .new(0,0,0,0);
        tb.BackgroundTransparency=1;
        tb.ScrollBarThickness=3;
        tb.ScrollBarImageColor3=He.scrollbar;
        tb.ScrollBarImageTransparency=0.29999999999999999;
        tb.BorderSizePixel=0;
        tb.Parent=Pa
        local tf=Instance.new'UIListLayout';
        tf.Padding=UDim.new(0,10);
        tf.SortOrder=Enum.SortOrder.LayoutOrder;
        tf.Parent=tb
        local function Ph(cg,pm,ra)
            local Lk=Instance.new'Frame';
            Lk.Size=UDim2 .new(1,0,0,110);
            Lk.BackgroundColor3=He.panelBg2;
            Lk.BackgroundTransparency=Hm.panel2;
            Lk.BorderSizePixel=0;
            Lk.LayoutOrder=ra;
            Lk.Parent=tb
            local Mj=Instance.new'UIStroke';
            Mj.Color=Color3 .fromRGB(50,55,70);
            Mj.Thickness=1;
            Mj.Transparency=0.5;
            Mj.Parent=Lk
            local yh=Instance.new'UICorner';
            yh.CornerRadius=UDim.new(0,10);
            yh.Parent=Lk
            local be=Instance.new'TextLabel';
            be.Size=UDim2 .new(1,-10,0,20);
            be.Position=UDim2 .new(0,5,0,5);
            be.BackgroundTransparency=1;
            be.Text=pm;
            be.TextColor3=He.textPrimary;
            be.TextSize=12;
            be.Font=Enum.Font.GothamBold;
            be.TextXAlignment=Enum.TextXAlignment.Left;
            be.Parent=Lk
            local c=Instance.new'TextButton';
            c.Size=UDim2 .new(1,-10,0,25);
            c.Position=UDim2 .new(0,5,0,30);
            c.BackgroundColor3=He.inputBg;
            c.BackgroundTransparency=Hm.input
            local Kf
            if ma[cg]and ma[cg]~=''then
                local Nd,hj;
                Nd,hj,Kf=pairs(md)
                while true do
                    local kc;
                    Kf,kc=Nd(hj,Kf)
                    if Kf==nil then
                        Kf='Select Animation...'
                        break
                    end
                    if tostring(kc)==tostring(ma[cg])then
                        break
                    end
                end
                if Kf=='Select Animation...'then
                    Kf='Custom Keyframes'
                end
            else
                Kf='Select Animation...'
            end
            c.Text=Kf;
            c.TextColor3=He.textSecond;
            c.TextSize=10;
            c.Font=Enum.Font.Gotham;
            c.TextXAlignment=Enum.TextXAlignment.Left;
            c.BorderSizePixel=0;
            c.Parent=Lk
            local Cd=Instance.new'UICorner';
            Cd.CornerRadius=UDim.new(0,7);
            Cd.Parent=c
            local Me=Instance.new'UIPadding';
            Me.PaddingLeft=UDim.new(0,8);
            Me.Parent=c
            local Cl=Instance.new'TextBox';
            Cl.Size=UDim2 .new(1,-10,0,40);
            Cl.Position=UDim2 .new(0,5,0,60);
            Cl.BackgroundColor3=He.inputBg;
            Cl.BackgroundTransparency=Hm.input;
            Cl.Text='';
            Cl.PlaceholderText='Or paste keyframe code...';
            Cl.TextColor3=He.textPrimary;
            Cl.PlaceholderColor3=He.textDim;
            Cl.TextSize=9;
            Cl.Font=Enum.Font.Code;
            Cl.TextWrapped=true;
            Cl.TextXAlignment=Enum.TextXAlignment.Left;
            Cl.TextYAlignment=Enum.TextYAlignment.Top;
            Cl.ClearTextOnFocus=false;
            Cl.MultiLine=true;
            Cl.BorderSizePixel=0;
            Cl.Parent=Lk
            local bc=Instance.new'UICorner';
            bc.CornerRadius=UDim.new(0,7);
            bc.Parent=Cl
            local cn,Vc=false,nil;
            c.MouseButton1Click:Connect(function()
                if cn then
                    if Vc then
                        Vc:Destroy()
                    end
                    cn=false
                else
                    cn=true;
                    Vc=Instance.new'Frame';
                    Vc.Size=UDim2 .new(1,0,0,180);
                    Vc.Position=UDim2 .new(0,0,1,2);
                    Vc.BackgroundColor3=He.panelBg2;
                    Vc.BackgroundTransparency=Hm.overlay;
                    Vc.BorderSizePixel=0;
                    Vc.ZIndex=10;
                    Vc.Parent=c
                    local Oc=Instance.new'UICorner';
                    Oc.CornerRadius=UDim.new(0,8);
                    Oc.Parent=Vc
                    local mh=Instance.new'TextBox';
                    mh.Size=UDim2 .new(1,-8,0,22);
                    mh.Position=UDim2 .new(0,4,0,4);
                    mh.BackgroundColor3=He.inputBg;
                    mh.BackgroundTransparency=Hm.input;
                    mh.Text='';
                    mh.PlaceholderText='Search...';
                    mh.TextColor3=He.textPrimary;
                    mh.PlaceholderColor3=He.textDim;
                    mh.TextSize=10;
                    mh.Font=Enum.Font.Gotham;
                    mh.BorderSizePixel=0;
                    mh.ZIndex=10;
                    mh.ClearTextOnFocus=false;
                    mh.Parent=Vc
                    local rk=Instance.new'UICorner';
                    rk.CornerRadius=UDim.new(0,6);
                    rk.Parent=mh
                    local Ab=Instance.new'ScrollingFrame';
                    Ab.Size=UDim2 .new(1,-4,1,-30);
                    Ab.Position=UDim2 .new(0,2,0,28);
                    Ab.BackgroundTransparency=1;
                    Ab.ScrollBarThickness=3;
                    Ab.ScrollBarImageColor3=He.scrollbar;
                    Ab.ScrollBarImageTransparency=0.29999999999999999;
                    Ab.BorderSizePixel=0;
                    Ab.ZIndex=10;
                    Ab.Parent=Vc
                    local we=Instance.new'UIListLayout';
                    we.Padding=UDim.new(0,2);
                    we.SortOrder=Enum.SortOrder.Name;
                    we.Parent=Ab
                    local Ke={}
                    local function ch()
                        local mc,qb,Gb=pairs(Ke)
                        while true do
                            local E;
                            Gb,E=mc(qb,Gb)
                            if Gb==nil then
                                break
                            end
                            E:Destroy()
                        end
                        Ke={}
                        local Wa,Od=mh.Text:lower(),Instance.new'TextButton';
                        Od.Size=UDim2 .new(1,0,0,22);
                        Od.BackgroundColor3=He.rowBg;
                        Od.BackgroundTransparency=Hm.row;
                        Od.Text='  [None]';
                        Od.TextColor3=He.textRed;
                        Od.TextSize=10;
                        Od.Font=Enum.Font.GothamBold;
                        Od.TextXAlignment=Enum.TextXAlignment.Left;
                        Od.BorderSizePixel=0;
                        Od.ZIndex=10;
                        Od.LayoutOrder=-1;
                        Od.Parent=Ab;
                        table.insert(Ke,Od);
                        Od.MouseButton1Click:Connect(function()
                            ma[cg]='';
                            Yc();
                            c.Text='Select Animation...';
                            Cl.Text=''
                            if Vc then
                                Vc:Destroy()
                            end
                            cn=false;
                            vd.Text=pm..' cleared';
                            vd.TextColor3=He.textYellow;
                            spawn(function()
                                wait(2);
                                vd.Text='Ready | '..ud;
                                vd.TextColor3=He.textDim
                            end)
                            if Pg then
                                local Si,mi,K=pairs(Uf)
                                while true do
                                    local pk;
                                    K,pk=Si(mi,K)
                                    if K==nil then
                                        break
                                    end
                                    if pk then
                                        pcall(function()
                                            pk:Disconnect()
                                        end)
                                    end
                                end
                                Uf={}
                                if Rf.isRunning then
                                    L()
                                end
                                task.wait(0.10000000000000001)
                                if Pg then
                                    Dm()
                                end
                            end
                        end)
                        local vb,tc,Ah=pairs(md)
                        local Fc,Vk={},0
                        while true do
                            local Tj;
                            Ah,Tj=vb(tc,Ah)
                            if Ah==nil then
                                break
                            end
                            if Wa==''or Ah:lower():find(Wa,1,true)then
                                table.insert(Fc,{name=Ah,id=Tj});
                                Vk=Vk+1
                                if 50<=Vk then
                                    break
                                end
                            end
                        end
                        table.sort(Fc,function(Za,bn)
                            return Za.name<bn.name
                        end)
                        for ba,qc in ipairs(Fc)do
                            local Jc=Instance.new'TextButton';
                            Jc.Size=UDim2 .new(1,0,0,22);
                            Jc.BackgroundColor3=He.rowBg;
                            Jc.BackgroundTransparency=Hm.row;
                            Jc.Text='  '..qc.name;
                            Jc.TextColor3=He.textPrimary;
                            Jc.TextSize=10;
                            Jc.Font=Enum.Font.Gotham;
                            Jc.TextXAlignment=Enum.TextXAlignment.Left;
                            Jc.BorderSizePixel=0;
                            Jc.ZIndex=10;
                            Jc.Parent=Ab;
                            table.insert(Ke,Jc);
                            Jc.MouseButton1Click:Connect(function()
                                ma[cg]=tostring(qc.id);
                                Yc();
                                c.Text=qc.name;
                                Cl.Text=''
                                if Vc then
                                    Vc:Destroy()
                                end
                                cn=false;
                                vd.Text=pm..' -> '..qc.name;
                                vd.TextColor3=He.textGreen;
                                spawn(function()
                                    wait(2);
                                    vd.Text='Ready | '..ud;
                                    vd.TextColor3=He.textDim
                                end)
                                if Pg then
                                    local xe,Bc,qj=pairs(Uf)
                                    while true do
                                        local vg;
                                        qj,vg=xe(Bc,qj)
                                        if qj==nil then
                                            break
                                        end
                                        if vg then
                                            pcall(function()
                                                vg:Disconnect()
                                            end)
                                        end
                                    end
                                    Uf={}
                                    if Rf.isRunning then
                                        L()
                                    end
                                    task.wait(0.10000000000000001)
                                    if Pg then
                                        Dm()
                                    end
                                end
                            end)
                        end
                        task.defer(function()
                            Ab.CanvasSize=UDim2 .new(0,0,0,we.AbsoluteContentSize.Y)
                        end)
                    end
                    ch()
                    local Jd=false;
                    mh:GetPropertyChangedSignal'Text':Connect(function()
                        if not Jd then
                            Jd=true;
                            task.wait(0.20000000000000001);
                            ch();
                            Jd=false
                        end
                    end)
                end
            end);
            Cl.FocusLost:Connect(function(Lg)
                if Cl.Text~=''then
                    ma[cg]=Cl.Text;
                    Yc();
                    c.Text='Custom Keyframes';
                    vd.Text=pm..' -> custom keyframes';
                    vd.TextColor3=He.textGreen;
                    spawn(function()
                        wait(2);
                        vd.Text='Ready | '..ud;
                        vd.TextColor3=He.textDim
                    end)
                    if Pg then
                        local Ma,Uj,m=pairs(Uf)
                        while true do
                            local zm;
                            m,zm=Ma(Uj,m)
                            if m==nil then
                                break
                            end
                            if zm then
                                pcall(function()
                                    zm:Disconnect()
                                end)
                            end
                        end
                        Uf={}
                        if Rf.isRunning then
                            L()
                        end
                        task.wait(0.10000000000000001)
                        if Pg then
                            Dm()
                        end
                    end
                end
            end)
        end
        Ph('idle','IDLE Animation',1);
        Ph('walking','WALKING Animation',2);
        Ph('jumping','JUMPING Animation',3);
        spawn(function()
            wait(0.10000000000000001);
            tb.CanvasSize=UDim2 .new(0,0,0,tf.AbsoluteContentSize.Y+10)
        end)
        local je=Instance.new'Frame';
        je.Size=UDim2 .new(1,-16,1,-175);
        je.Position=UDim2 .new(0,8,0,104);
        je.BackgroundTransparency=1;
        je.Visible=false;
        je.Parent=sg
        local yg=Instance.new'TextLabel';
        yg.Size=UDim2 .new(1,0,0,25);
        yg.Position=UDim2 .new(0,0,0,10);
        yg.BackgroundTransparency=1;
        yg.Text='Height: 1.00x';
        yg.TextColor3=He.textPrimary;
        yg.TextSize=12;
        yg.Font=Enum.Font.GothamBold;
        yg.TextXAlignment=Enum.TextXAlignment.Left;
        yg.Parent=je
        local fe=Instance.new'Frame';
        fe.Size=UDim2 .new(1,-20,0,5);
        fe.Position=UDim2 .new(0,10,0,45);
        fe.BackgroundColor3=He.toggleOff;
        fe.BackgroundTransparency=0.20000000000000001;
        fe.BorderSizePixel=0;
        fe.Parent=je
        local Ff=Instance.new'UICorner';
        Ff.CornerRadius=UDim.new(0,3);
        Ff.Parent=fe
        local uh=Instance.new'Frame';
        uh.Size=UDim2 .new(0,14,0,14);
        uh.Position=UDim2 .new(0.5,-7,0.5,-7);
        uh.BackgroundColor3=He.textPrimary;
        uh.BackgroundTransparency=0.10000000000000001;
        uh.BorderSizePixel=0;
        uh.Parent=fe
        local ke=Instance.new'UICorner';
        ke.CornerRadius=UDim.new(0,7);
        ke.Parent=uh
        local nm=Instance.new'TextLabel';
        nm.Size=UDim2 .new(1,0,0,25);
        nm.Position=UDim2 .new(0,0,0,80);
        nm.BackgroundTransparency=1;
        nm.Text='Width: 1.00x';
        nm.TextColor3=He.textPrimary;
        nm.TextSize=12;
        nm.Font=Enum.Font.GothamBold;
        nm.TextXAlignment=Enum.TextXAlignment.Left;
        nm.Parent=je
        local Yg=Instance.new'Frame';
        Yg.Size=UDim2 .new(1,-20,0,5);
        Yg.Position=UDim2 .new(0,10,0,115);
        Yg.BackgroundColor3=He.toggleOff;
        Yg.BackgroundTransparency=0.20000000000000001;
        Yg.BorderSizePixel=0;
        Yg.Parent=je
        local Gh=Instance.new'UICorner';
        Gh.CornerRadius=UDim.new(0,3);
        Gh.Parent=Yg
        local qi=Instance.new'Frame';
        qi.Size=UDim2 .new(0,14,0,14);
        qi.Position=UDim2 .new(0.5,-7,0.5,-7);
        qi.BackgroundColor3=He.textPrimary;
        qi.BackgroundTransparency=0.10000000000000001;
        qi.BorderSizePixel=0;
        qi.Parent=Yg
        local Bb=Instance.new'UICorner';
        Bb.CornerRadius=UDim.new(0,7);
        Bb.Parent=qi
        local za=Instance.new'TextButton';
        za.Size=UDim2 .new(0,100,0,28);
        za.Position=UDim2 .new(0.5,-50,0,160);
        za.BackgroundColor3=He.btnBg;
        za.BackgroundTransparency=Hm.btn;
        za.Text='Reset Size';
        za.TextColor3=He.textPrimary;
        za.TextSize=11;
        za.Font=Enum.Font.GothamSemibold;
        za.BorderSizePixel=0;
        za.Parent=je
        local Dd=Instance.new'UICorner';
        Dd.CornerRadius=UDim.new(0,9);
        Dd.Parent=za
        local Qi,Mm=false,false
        local function Eh(Oe)
            aa.heightScale=0.10000000000000001*math.pow(1000,Oe);
            uh.Position=UDim2 .new(Oe,-7,0.5,-7);
            yg.Text=string.format('Height: %.2fx',aa.heightScale)
            if Pg then
                Bg()
            end
        end
        local function cm(Bd)
            aa.widthScale=0.10000000000000001*math.pow(1000,Bd);
            qi.Position=UDim2 .new(Bd,-7,0.5,-7);
            nm.Text=string.format('Width: %.2fx',aa.widthScale)
            if Pg then
                Bg()
            end
        end
        local function Tb(wk)
            Eh(math.clamp((wk.Position.X-fe.AbsolutePosition.X)/fe.AbsoluteSize.X,0,1))
        end
        local function pc(t_)
            cm(math.clamp((t_.Position.X-Yg.AbsolutePosition.X)/Yg.AbsoluteSize.X,0,1))
        end
        uh.InputBegan:Connect(function(ib)
            if ib.UserInputType==Enum.UserInputType.MouseButton1 or ib.UserInputType==Enum.UserInputType.Touch then
                Qi=true;
                Tb(ib)
            end
        end);
        qi.InputBegan:Connect(function(X)
            if X.UserInputType==Enum.UserInputType.MouseButton1 or X.UserInputType==Enum.UserInputType.Touch then
                Mm=true;
                pc(X)
            end
        end);
        cb.InputChanged:Connect(function(oh)
            if Qi and(oh.UserInputType==Enum.UserInputType.MouseMovement or oh.UserInputType==Enum.UserInputType.Touch)then
                Tb(oh)
            end
            if Mm and(oh.UserInputType==Enum.UserInputType.MouseMovement or oh.UserInputType==Enum.UserInputType.Touch)then
                pc(oh)
            end
        end);
        cb.InputEnded:Connect(function(nj)
            if nj.UserInputType==Enum.UserInputType.MouseButton1 or nj.UserInputType==Enum.UserInputType.Touch then
                Qi=false;
                Mm=false
            end
        end);
        za.MouseButton1Click:Connect(function()
            aa.heightScale=1;
            aa.widthScale=1;
            uh.Position=UDim2 .new(0.5,-7,0.5,-7);
            qi.Position=UDim2 .new(0.5,-7,0.5,-7);
            yg.Text='Height: 1.00x';
            nm.Text='Width: 1.00x'
            if Pg then
                Bg()
            end
        end);
        za.MouseEnter:Connect(function()
            za.BackgroundTransparency=Hm.btnH
        end);
        za.MouseLeave:Connect(function()
            za.BackgroundTransparency=Hm.btn
        end)
        local rd=Instance.new'Frame';
        rd.Size=UDim2 .new(1,-16,1,-175);
        rd.Position=UDim2 .new(0,8,0,104);
        rd.BackgroundTransparency=1;
        rd.Visible=false;
        rd.Parent=sg
        local Fd=Instance.new'TextLabel';
        Fd.Size=UDim2 .new(1,0,0,28);
        Fd.Position=UDim2 .new(0,0,0,-5);
        Fd.BackgroundTransparency=1;
        Fd.Text='Drop folder: \"Drop JSON FILES HERE\"';
        Fd.TextColor3=He.textSecond;
        Fd.TextSize=10;
        Fd.Font=Enum.Font.GothamSemibold;
        Fd.TextXAlignment=Enum.TextXAlignment.Left;
        Fd.TextWrapped=true;
        Fd.Parent=rd
        local id=Instance.new'TextButton';
        id.Size=UDim2 .new(0,110,0,22);
        id.Position=UDim2 .new(0,0,0,28);
        id.BackgroundColor3=He.btnBg;
        id.BackgroundTransparency=Hm.btn;
        id.Text='Reload JSON Files';
        id.TextColor3=He.textPrimary;
        id.TextSize=9;
        id.Font=Enum.Font.Gotham;
        id.BorderSizePixel=0;
        id.Parent=rd
        local od=Instance.new'UICorner';
        od.CornerRadius=UDim.new(0,7);
        od.Parent=id;
        id.MouseButton1Click:Connect(function()
            bd();
            vd.Text='JSON files reloaded';
            vd.TextColor3=He.textGreen;
            spawn(function()
                wait(2);
                vd.Text='Ready | '..ud;
                vd.TextColor3=He.textDim
            end)
        end);
        id.MouseEnter:Connect(function()
            id.BackgroundTransparency=Hm.btnH
        end);
        id.MouseLeave:Connect(function()
            id.BackgroundTransparency=Hm.btn
        end)
        local Yh=Instance.new'TextLabel';
        Yh.Size=UDim2 .new(1,0,0,20);
        Yh.Position=UDim2 .new(0,0,0,57);
        Yh.BackgroundTransparency=1;
        Yh.Text='Hide Bodyparts';
        Yh.TextColor3=He.textPrimary;
        Yh.TextSize=12;
        Yh.Font=Enum.Font.GothamBold;
        Yh.TextXAlignment=Enum.TextXAlignment.Left;
        Yh.Parent=rd
        local pi=Instance.new'TextButton';
        pi.Size=UDim2 .new(1,0,0,28);
        pi.Position=UDim2 .new(0,0,0,79);
        pi.BackgroundColor3=He.btnBg;
        pi.BackgroundTransparency=Hm.btn;
        pi.Text='  Select Body Parts...';
        pi.TextColor3=He.textPrimary;
        pi.TextSize=10;
        pi.Font=Enum.Font.Gotham;
        pi.TextXAlignment=Enum.TextXAlignment.Left;
        pi.BorderSizePixel=0;
        pi.Parent=rd
        local Fh=Instance.new'UICorner';
        Fh.CornerRadius=UDim.new(0,9);
        Fh.Parent=pi
        local Tl=Instance.new'UIPadding';
        Tl.PaddingLeft=UDim.new(0,10);
        Tl.Parent=pi
        local U={'Head','UpperTorso','LowerTorso','LeftUpperArm','LeftLowerArm','LeftHand','RightUpperArm','RightLowerArm','RightHand','LeftUpperLeg','LeftLowerLeg','LeftFoot','RightUpperLeg','RightLowerLeg','RightFoot','Torso','Left Arm','Right Arm','Left Leg','Right Leg'}
        local function ii(eh)
            if Pg and(Dh and xm)then
                local Sj,W=Dh:FindFirstChild(eh),xm:FindFirstChild(eh)
                if Sj and Sj:IsA'BasePart'then
                    if W and W:IsA'BasePart'then
                        Sj.Transparency=1;
                        Sj.CanCollide=false
                        if eh=='Head'then
                            for lf,Jh in ipairs(Sj:GetChildren())do
                                if Jh:IsA'Decal'then
                                    Jh.Transparency=1
                                end
                            end
                        end
                        _G.hiddenBodyParts[eh]=true
                    end
                end
            end
        end
        local function Ul(Ve)
            _G.hiddenBodyParts[Ve]=nil
        end
        local Lm,Vm=false,nil;
        pi.MouseButton1Click:Connect(function()
            if Lm then
                if Vm then
                    Vm:Destroy()
                end
                Lm=false
                return
            elseif Pg and Dh then
                Lm=true;
                Vm=Instance.new'Frame';
                Vm.Size=UDim2 .new(1,0,0,150);
                Vm.Position=UDim2 .new(0,0,1,3);
                Vm.BackgroundColor3=He.panelBg2;
                Vm.BackgroundTransparency=Hm.overlay;
                Vm.BorderSizePixel=0;
                Vm.ZIndex=10;
                Vm.Parent=pi
                local _e=Instance.new'UICorner';
                _e.CornerRadius=UDim.new(0,9);
                _e.Parent=Vm
                local qm=Instance.new'ScrollingFrame';
                qm.Size=UDim2 .new(1,-6,1,-6);
                qm.Position=UDim2 .new(0,3,0,3);
                qm.BackgroundTransparency=1;
                qm.ScrollBarThickness=3;
                qm.ScrollBarImageColor3=He.scrollbar;
                qm.ScrollBarImageTransparency=0.29999999999999999;
                qm.BorderSizePixel=0;
                qm.ZIndex=10;
                qm.Parent=Vm
                local qk=Instance.new'UIListLayout';
                qk.Padding=UDim.new(0,2);
                qk.SortOrder=Enum.SortOrder.Name;
                qk.Parent=qm
                for Mc,Yf in ipairs(U)do
                    if Dh:FindFirstChild(Yf)~=nil then
                        local Vi=Instance.new'TextButton';
                        Vi.Size=UDim2 .new(1,0,0,24);
                        Vi.BackgroundColor3=He.rowBg;
                        Vi.BackgroundTransparency=Hm.row;
                        Vi.Text=(_G.hiddenBodyParts[Yf]and'[x] 'or'   ')..Yf;
                        Vi.TextColor3=_G.hiddenBodyParts[Yf]and He.accentPlay or He.textPrimary;
                        Vi.TextSize=9;
                        Vi.Font=Enum.Font.Gotham;
                        Vi.TextXAlignment=Enum.TextXAlignment.Left;
                        Vi.BorderSizePixel=0;
                        Vi.ZIndex=10;
                        Vi.Parent=qm
                        local of=Instance.new'UIPadding';
                        of.PaddingLeft=UDim.new(0,5);
                        of.Parent=Vi;
                        Vi.MouseButton1Click:Connect(function()
                            if _G.hiddenBodyParts[Yf]then
                                Ul(Yf);
                                vd.Text=Yf..' shown';
                                vd.TextColor3=He.textYellow
                            else
                                ii(Yf);
                                vd.Text=Yf..' hidden';
                                vd.TextColor3=He.textGreen
                            end
                            spawn(function()
                                wait(2);
                                vd.Text='Ready | '..ud;
                                vd.TextColor3=He.textDim
                            end);
                            Vi.Text=(_G.hiddenBodyParts[Yf]and'[x] 'or'   ')..Yf;
                            Vi.TextColor3=_G.hiddenBodyParts[Yf]and He.accentPlay or He.textPrimary
                        end)
                    end
                end
                spawn(function()
                    wait(0.050000000000000003);
                    qm.CanvasSize=UDim2 .new(0,0,0,qk.AbsoluteContentSize.Y)
                end)
            else
                vd.Text='Enable reanimation first!';
                vd.TextColor3=He.textRed;
                spawn(function()
                    wait(2);
                    vd.Text='Ready | '..ud;
                    vd.TextColor3=He.textDim
                end)
            end
        end);
        pi.MouseEnter:Connect(function()
            pi.BackgroundTransparency=Hm.btnH
        end);
        pi.MouseLeave:Connect(function()
            pi.BackgroundTransparency=Hm.btn
        end)
        local function Yi(wh_,R,ug)
            local Bj=Instance.new'TextLabel';
            Bj.Size=UDim2 .new(0.69999999999999996,0,0,20);
            Bj.Position=UDim2 .new(0,0,0,R);
            Bj.BackgroundTransparency=1;
            Bj.Text=wh_;
            Bj.TextColor3=He.textPrimary;
            Bj.TextSize=12;
            Bj.Font=Enum.Font.GothamBold;
            Bj.TextXAlignment=Enum.TextXAlignment.Left;
            Bj.Parent=rd
            local fc=Instance.new'Frame';
            fc.Size=UDim2 .new(0,40,0,18);
            fc.Position=UDim2 .new(1,-45,0,R+1);
            fc.BackgroundColor3=He.toggleOff;
            fc.BackgroundTransparency=0;
            fc.BorderSizePixel=0;
            fc.Parent=rd
            local ye=Instance.new'UICorner';
            ye.CornerRadius=UDim.new(0,9);
            ye.Parent=fc
            local pb=Instance.new'Frame';
            pb.Size=UDim2 .new(0,14,0,14);
            pb.Position=UDim2 .new(0,2,0,2);
            pb.BackgroundColor3=He.knobOff;
            pb.BorderSizePixel=0;
            pb.Parent=fc
            local fa_=Instance.new'UICorner';
            fa_.CornerRadius=UDim.new(0,7);
            fa_.Parent=pb
            local si=Instance.new'TextButton';
            si.Size=UDim2 .new(1,0,1,0);
            si.BackgroundTransparency=1;
            si.Text='';
            si.Parent=fc;
            si.MouseButton1Click:Connect(function()
                ug(fc,pb)
            end)
            return fc,pb
        end
        local Pf,Mh=Yi('Snake Mode',115,function(Nc,Ic)
            if Pg then
                yk=not yk;
                zk={};
                Rl={};
                p={}
                if yk then
                    Nc.BackgroundColor3=He.toggleOn;
                    Ic.Position=UDim2 .new(1,-16,0,2);
                    Ic.BackgroundColor3=He.knobOn;
                    vd.Text='Snake mode on';
                    vd.TextColor3=He.textGreen
                else
                    Nc.BackgroundColor3=He.toggleOff;
                    Ic.Position=UDim2 .new(0,2,0,2);
                    Ic.BackgroundColor3=He.knobOff;
                    vd.Text='Snake mode off';
                    vd.TextColor3=He.textYellow
                end
                spawn(function()
                    wait(2);
                    vd.Text='Ready | '..ud;
                    vd.TextColor3=He.textDim
                end)
            else
                vd.Text='Enable reanimation first!';
                vd.TextColor3=He.textRed;
                spawn(function()
                    wait(2);
                    vd.Text='Ready | '..ud;
                    vd.TextColor3=He.textDim
                end)
            end
        end)
        local Z=Instance.new'TextLabel';
        Z.Size=UDim2 .new(1,-60,0,18);
        Z.Position=UDim2 .new(0,0,0,140);
        Z.BackgroundTransparency=1;
        Z.Text='Distance: 1.00';
        Z.TextColor3=He.textSecond;
        Z.TextSize=10;
        Z.Font=Enum.Font.Gotham;
        Z.TextXAlignment=Enum.TextXAlignment.Left;
        Z.Parent=rd
        local lk=Instance.new'Frame';
        lk.Size=UDim2 .new(1,-10,0,4);
        lk.Position=UDim2 .new(0,5,0,160);
        lk.BackgroundColor3=He.toggleOff;
        lk.BackgroundTransparency=0.20000000000000001;
        lk.BorderSizePixel=0;
        lk.Parent=rd
        local Sl=Instance.new'UICorner';
        Sl.CornerRadius=UDim.new(0,2);
        Sl.Parent=lk
        local he=Instance.new'Frame';
        he.Size=UDim2 .new(0,12,0,12);
        he.Position=UDim2 .new(0.17999999999999999,-6,0.5,-6);
        he.BackgroundColor3=He.textPrimary;
        he.BackgroundTransparency=0.10000000000000001;
        he.BorderSizePixel=0;
        he.Parent=lk
        local Wm=Instance.new'UICorner';
        Wm.CornerRadius=UDim.new(0,6);
        Wm.Parent=he
        local _c=false
        local function Xc(tm)
            Ij=0.20000000000000001+tm*4.7999999999999998;
            he.Position=UDim2 .new(tm,-6,0.5,-6);
            Z.Text=string.format('Distance: %.2f',Ij)
        end
        local function Ec(fb)
            Xc(math.clamp((fb.Position.X-lk.AbsolutePosition.X)/lk.AbsoluteSize.X,0,1))
        end
        he.InputBegan:Connect(function(Ua)
            if Ua.UserInputType==Enum.UserInputType.MouseButton1 or Ua.UserInputType==Enum.UserInputType.Touch then
                _c=true;
                Ec(Ua)
            end
        end);
        cb.InputChanged:Connect(function(xc)
            if _c and(xc.UserInputType==Enum.UserInputType.MouseMovement or xc.UserInputType==Enum.UserInputType.Touch)then
                Ec(xc)
            end
        end);
        cb.InputEnded:Connect(function(Qg)
            if Qg.UserInputType==Enum.UserInputType.MouseButton1 or Qg.UserInputType==Enum.UserInputType.Touch then
                _c=false
            end
        end);
        Yi('Cover Sky (need layered clothing)',175,function(Mb,qh)
            if Pg then
                la=not la
                if la then
                    Mb.BackgroundColor3=He.toggleOn;
                    qh.Position=UDim2 .new(1,-16,0,2);
                    qh.BackgroundColor3=He.knobOn;
                    vd.Text='Cover Sky on';
                    vd.TextColor3=He.textGreen
                else
                    Mb.BackgroundColor3=He.toggleOff;
                    qh.Position=UDim2 .new(0,2,0,2);
                    qh.BackgroundColor3=He.knobOff;
                    vd.Text='Cover Sky off';
                    vd.TextColor3=He.textYellow
                end
                spawn(function()
                    wait(2);
                    vd.Text='Ready | '..ud;
                    vd.TextColor3=He.textDim
                end)
            else
                vd.Text='Enable reanimation first!';
                vd.TextColor3=He.textRed;
                spawn(function()
                    wait(2);
                    vd.Text='Ready | '..ud;
                    vd.TextColor3=He.textDim
                end)
            end
        end);
        Yi('Cover Ground (need layered clothing)',203,function(Dj,Mi)
            if Pg then
                groundModeEnabled=not groundModeEnabled
                if groundModeEnabled then
                    Dj.BackgroundColor3=He.toggleOn;
                    Mi.Position=UDim2 .new(1,-16,0,2);
                    Mi.BackgroundColor3=He.knobOn;
                    vd.Text='Cover Ground on';
                    vd.TextColor3=He.textGreen
                else
                    Dj.BackgroundColor3=He.toggleOff;
                    Mi.Position=UDim2 .new(0,2,0,2);
                    Mi.BackgroundColor3=He.knobOff;
                    vd.Text='Cover Ground off';
                    vd.TextColor3=He.textYellow
                end
                spawn(function()
                    wait(2);
                    vd.Text='Ready | '..ud;
                    vd.TextColor3=He.textDim
                end)
            else
                vd.Text='Enable reanimation first!';
                vd.TextColor3=He.textRed;
                spawn(function()
                    wait(2);
                    vd.Text='Ready | '..ud;
                    vd.TextColor3=He.textDim
                end)
            end
        end)
        local Zd=Instance.new'TextButton';
        Zd.Size=UDim2 .new(0,60,0,22);
        Zd.Position=UDim2 .new(0,8,0,104);
        Zd.BackgroundColor3=He.btnBg;
        Zd.BackgroundTransparency=Hm.btn;
        Zd.Text='Add';
        Zd.TextColor3=He.textPrimary;
        Zd.TextSize=10;
        Zd.Font=Enum.Font.GothamSemibold;
        Zd.BorderSizePixel=0;
        Zd.Parent=sg
        local Tm=Instance.new'UICorner';
        Tm.CornerRadius=UDim.new(0,9);
        Tm.Parent=Zd
        local Ee=Instance.new'TextButton';
        Ee.Size=UDim2 .new(0,25,0,25);
        Ee.Position=UDim2 .new(1,-33,1,-33);
        Ee.BackgroundColor3=He.btnBg;
        Ee.BackgroundTransparency=Hm.btn;
        Ee.Text='?';
        Ee.TextColor3=He.textSecond;
        Ee.TextSize=14;
        Ee.Font=Enum.Font.GothamBold;
        Ee.BorderSizePixel=0;
        Ee.ZIndex=10;
        Ee.Visible=false;
        Ee.Parent=sg
        local ih=Instance.new'UICorner';
        ih.CornerRadius=UDim.new(1,0);
        ih.Parent=Ee;
        Ee.MouseEnter:Connect(function()
            Ee.BackgroundTransparency=Hm.btnH
        end);
        Ee.MouseLeave:Connect(function()
            Ee.BackgroundTransparency=Hm.btn
        end)
        local Al=nil
        local function Wf()
            if Al then
                Al:Destroy()
            end
            Al=Instance.new'Frame';
            Al.Size=UDim2 .new(0,380,0,310);
            Al.Position=UDim2 .new(0.5,-190,0.5,-155);
            Al.BackgroundColor3=He.panelBg;
            Al.BackgroundTransparency=Hm.panel;
            Al.BorderSizePixel=0;
            Al.ZIndex=100;
            Al.Parent=_f
            local hl=Instance.new'UIStroke';
            hl.Color=Color3 .fromRGB(70,75,90);
            hl.Thickness=1;
            hl.Transparency=0.29999999999999999;
            hl.Parent=Al
            local km=Instance.new'UICorner';
            km.CornerRadius=UDim.new(0,14);
            km.Parent=Al
            local hb=Instance.new'TextLabel';
            hb.Size=UDim2 .new(1,-40,0,30);
            hb.Position=UDim2 .new(0,10,0,5);
            hb.BackgroundTransparency=1;
            hb.Text='AC Reanim - How to Convert Animations';
            hb.TextColor3=He.textPrimary;
            hb.TextSize=13;
            hb.Font=Enum.Font.GothamBold;
            hb.TextXAlignment=Enum.TextXAlignment.Left;
            hb.ZIndex=101;
            hb.Parent=Al
            local ah=Instance.new'TextButton';
            ah.Size=UDim2 .new(0,25,0,25);
            ah.Position=UDim2 .new(1,-30,0,5);
            ah.BackgroundColor3=He.btnBg;
            ah.BackgroundTransparency=Hm.btn;
            ah.Text='X';
            ah.TextColor3=He.textPrimary;
            ah.TextSize=16;
            ah.Font=Enum.Font.Gotham;
            ah.BorderSizePixel=0;
            ah.ZIndex=101;
            ah.Parent=Al
            local Ae=Instance.new'UICorner';
            Ae.CornerRadius=UDim.new(0,8);
            Ae.Parent=ah;
            ah.MouseButton1Click:Connect(function()
                Al:Destroy();
                Al=nil
            end)
            local wg=Instance.new'TextLabel';
            wg.Size=UDim2 .new(1,-20,0,160);
            wg.Position=UDim2 .new(0,10,0,40);
            wg.BackgroundTransparency=1;
            wg.Text='1. Open Roblox Studio and create a new game\n\n\50. Create a Folder in Workspace named \"Keyframes\"\n\n\51. Put all your KeyframeSequences in the folder\n   (Each animation should be named differently)\n\n\52. Publish your game to Roblox\n\n\53. Join the published game with your executor\n\n\54. Execute the converter script below:\n\nCustom JSON folder: Drop JSON FILES HERE/\n   Drop {\"Name\":\"animId\"} JSON files to auto-add to Custom tab';
            wg.TextColor3=He.textPrimary;
            wg.TextSize=11;
            wg.Font=Enum.Font.Gotham;
            wg.TextXAlignment=Enum.TextXAlignment.Left;
            wg.TextYAlignment=Enum.TextYAlignment.Top;
            wg.TextWrapped=true;
            wg.ZIndex=101;
            wg.Parent=Al
            local Hb=Instance.new'Frame';
            Hb.Size=UDim2 .new(1,-20,0,40);
            Hb.Position=UDim2 .new(0,10,0,210);
            Hb.BackgroundColor3=He.inputBg;
            Hb.BackgroundTransparency=Hm.input;
            Hb.BorderSizePixel=0;
            Hb.ZIndex=101;
            Hb.Parent=Al
            local Jk=Instance.new'UICorner';
            Jk.CornerRadius=UDim.new(0,8);
            Jk.Parent=Hb
            local ac=Instance.new'TextBox';
            ac.Size=UDim2 .new(1,-10,1,-10);
            ac.Position=UDim2 .new(0,5,0,5);
            ac.BackgroundTransparency=1;
            ac.Text='loadstring(game:HttpGet(\"https://akadmin-bzk.pages.dev/Converter.lua\"))()';
            ac.TextColor3=He.textGreen;
            ac.TextSize=10;
            ac.Font=Enum.Font.Code;
            ac.TextWrapped=true;
            ac.TextEditable=false;
            ac.TextXAlignment=Enum.TextXAlignment.Left;
            ac.TextYAlignment=Enum.TextYAlignment.Center;
            ac.ClearTextOnFocus=false;
            ac.ZIndex=102;
            ac.Parent=Hb
            local ue=Instance.new'TextButton';
            ue.Size=UDim2 .new(0,60,0,25);
            ue.Position=UDim2 .new(0.5,-30,1,10);
            ue.BackgroundColor3=He.btnBg;
            ue.BackgroundTransparency=Hm.btn;
            ue.Text='Copy';
            ue.TextColor3=He.textPrimary;
            ue.TextSize=11;
            ue.Font=Enum.Font.Gotham;
            ue.BorderSizePixel=0;
            ue.ZIndex=102;
            ue.Parent=Hb
            local Zl=Instance.new'UICorner';
            Zl.CornerRadius=UDim.new(0,7);
            Zl.Parent=ue;
            ue.MouseEnter:Connect(function()
                ue.BackgroundTransparency=Hm.btnH
            end);
            ue.MouseLeave:Connect(function()
                ue.BackgroundTransparency=Hm.btn
            end);
            ue.MouseButton1Click:Connect(function()
                setclipboard(ac.Text);
                ue.Text='Copied!';
                spawn(function()
                    wait(1.5);
                    ue.Text='Copy'
                end)
            end)
        end
        Ee.MouseButton1Click:Connect(Wf)
        local If=Instance.new'Frame';
        If.Size=UDim2 .new(1,-16,0,65);
        If.Position=UDim2 .new(0,8,1,-70);
        If.BackgroundTransparency=1;
        If.Parent=sg
        local td=Instance.new'TextLabel';
        td.Size=UDim2 .new(0,45,0,18);
        td.Position=UDim2 .new(0,0,0,0);
        td.BackgroundTransparency=1;
        td.Text='Speed:';
        td.TextColor3=He.textSecond;
        td.TextSize=9;
        td.Font=Enum.Font.Gotham;
        td.TextXAlignment=Enum.TextXAlignment.Left;
        td.Parent=If
        local yf=Instance.new'Frame';
        yf.Size=UDim2 .new(1,-100,0,5);
        yf.Position=UDim2 .new(0,45,0,7);
        yf.BackgroundColor3=He.toggleOff;
        yf.BackgroundTransparency=0.20000000000000001;
        yf.BorderSizePixel=0;
        yf.Parent=If
        local va=Instance.new'UICorner';
        va.CornerRadius=UDim.new(0,3);
        va.Parent=yf
        local Rh=Instance.new'Frame';
        Rh.Size=UDim2 .new(0,12,0,12);
        Rh.Position=UDim2 .new(0.5,-6,0.5,-6);
        Rh.BackgroundColor3=He.textPrimary;
        Rh.BackgroundTransparency=0.10000000000000001;
        Rh.BorderSizePixel=0;
        Rh.Parent=yf
        local Ld=Instance.new'UICorner';
        Ld.CornerRadius=UDim.new(0,6);
        Ld.Parent=Rh
        local Of=Instance.new'TextLabel';
        Of.Size=UDim2 .new(0,28,0,18);
        Of.Position=UDim2 .new(1,4,0.5,-9);
        Of.BackgroundTransparency=1;
        Of.Text='5';
        Of.TextColor3=He.textSecond;
        Of.TextSize=9;
        Of.Font=Enum.Font.Gotham;
        Of.TextXAlignment=Enum.TextXAlignment.Left;
        Of.ZIndex=2;
        Of.Parent=yf
        local Km=Instance.new'TextButton';
        Km.Size=UDim2 .new(0,32,0,14);
        Km.Position=UDim2 .new(1,-32,0,2);
        Km.BackgroundColor3=He.btnBg;
        Km.BackgroundTransparency=Hm.btn;
        Km.Text='Reset';
        Km.TextColor3=He.textSecond;
        Km.TextSize=7;
        Km.Font=Enum.Font.Gotham;
        Km.BorderSizePixel=0;
        Km.Parent=If
        local ng=Instance.new'UICorner';
        ng.CornerRadius=UDim.new(0,7);
        ng.Parent=Km
        local kh=Instance.new'Frame';
        kh.Size=UDim2 .new(1,0,0,38);
        kh.Position=UDim2 .new(0,0,0,22);
        kh.BackgroundTransparency=1;
        kh.Parent=If
        local Th,Zm,_l,Ob,ne,tl,ij='all',false,false,false,nil,false,{}
        for gi=1,5 do
            local rg,ph=gi,Instance.new'Frame';
            ph.Size=UDim2 .new(0.17999999999999999,0,1,0);
            ph.Position=UDim2 .new((rg-1)*0.20000000000000001+0.01,0,0,0);
            ph.BackgroundTransparency=1;
            ph.Parent=kh
            local a_=Instance.new'TextBox';
            a_.Size=UDim2 .new(1,0,0,16);
            a_.Position=UDim2 .new(0,0,0,0);
            a_.BackgroundColor3=He.inputBg;
            a_.BackgroundTransparency=Hm.input;
            a_.Text=Sg and Sg[rg]and tostring(Sg[rg].speed)or tostring(rg*2-1);
            a_.TextColor3=He.textPrimary;
            a_.TextSize=8;
            a_.Font=Enum.Font.Gotham;
            a_.BorderSizePixel=0;
            a_.Parent=ph
            local cd=Instance.new'UICorner';
            cd.CornerRadius=UDim.new(0,5);
            cd.Parent=a_
            local Kb=Instance.new'TextButton';
            Kb.Size=UDim2 .new(1,0,0,16);
            Kb.Position=UDim2 .new(0,0,0,20);
            Kb.BackgroundColor3=He.btnBg;
            Kb.BackgroundTransparency=Hm.btn;
            Kb.Text='Key';
            Kb.TextColor3=He.textSecond;
            Kb.TextSize=7;
            Kb.Font=Enum.Font.Gotham;
            Kb.BorderSizePixel=0;
            Kb.Parent=ph
            local ze=Instance.new'UICorner';
            ze.CornerRadius=UDim.new(0,5);
            ze.Parent=Kb;
            ij[rg]={speedInput=a_,keybindButton=Kb,connection=nil};
            a_.FocusLost:Connect(function()
                if not Sg[rg]then
                    Sg[rg]={speed=rg*2-1,key=''}
                end
                local u_=tonumber(a_.Text)
                if u_ and(0<=u_ and u_<=10)then
                    Sg[rg].speed=u_;
                    ji()
                else
                    a_.Text=tostring(Sg[rg].speed)
                end
            end);
            Kb.MouseButton1Click:Connect(function()
                if not Sg[rg]then
                    Sg[rg]={speed=rg*2-1,key=''}
                end
                if Sg[rg].key==''then
                    Kb.Text='...';
                    vd.Text='Press any key for slot '..rg..'...';
                    vd.TextColor3=He.textYellow
                    local am=nil;
                    am=cb.InputBegan:Connect(function(S,Se)
                        if not Se then
                            if S.KeyCode==Enum.KeyCode.Escape or S.KeyCode==Enum.KeyCode.Backspace then
                                Kb.Text='Key';
                                vd.Text='Cancelled';
                                vd.TextColor3=He.textDim;
                                spawn(function()
                                    wait(2);
                                    vd.Text='Ready | '..ud
                                end);
                                am:Disconnect()
                            elseif S.KeyCode~=Enum.KeyCode.Unknown then
                                Sg[rg].key=S.KeyCode.Name;
                                Kb.Text=S.KeyCode.Name:sub(1,3);
                                Kb.TextColor3=He.textPrimary;
                                ji()
                                if ij[rg].connection then
                                    ij[rg].connection:Disconnect()
                                end
                                ij[rg].connection=cb.InputBegan:Connect(function(Ta,vm)
                                    if not vm then
                                        if Ta.KeyCode==S.KeyCode then
                                            local Xf=Sg[rg].speed/10;
                                            Rf.speed=Sg[rg].speed/5;
                                            Rh.Position=UDim2 .new(Xf,-6,0.5,-6);
                                            Of.Text=string.format('%d',Sg[rg].speed)
                                        end
                                    end
                                end);
                                vd.Text='Bound slot '..rg..' -> '..S.KeyCode.Name;
                                vd.TextColor3=He.textGreen;
                                spawn(function()
                                    wait(2);
                                    vd.Text='Ready | '..ud;
                                    vd.TextColor3=He.textDim
                                end);
                                am:Disconnect()
                            end
                        end
                    end)
                else
                    Sg[rg].key='';
                    Kb.Text='Key';
                    Kb.TextColor3=He.textSecond;
                    ji()
                    if ij[rg].connection then
                        ij[rg].connection:Disconnect();
                        ij[rg].connection=nil
                    end
                    vd.Text='Unbound slot '..rg;
                    vd.TextColor3=He.textRed;
                    spawn(function()
                        wait(2);
                        vd.Text='Ready | '..ud;
                        vd.TextColor3=He.textDim
                    end)
                end
            end)
        end
        for ca=1,5 do
            local Ti=ca
            if Sg[Ti]then
                ij[Ti].speedInput.Text=tostring(Sg[Ti].speed)
                if Sg[Ti].key and Sg[Ti].key~=''then
                    ij[Ti].keybindButton.Text=Sg[Ti].key:sub(1,3);
                    ij[Ti].keybindButton.TextColor3=He.textPrimary
                    local Ch=Enum.KeyCode[Sg[Ti].key]
                    if Ch then
                        ij[Ti].connection=cb.InputBegan:Connect(function(Sc,Qj)
                            if not Qj then
                                if Sc.KeyCode==Ch then
                                    local ub=Sg[Ti].speed/10;
                                    Rf.speed=Sg[Ti].speed/5;
                                    Rh.Position=UDim2 .new(ub,-6,0.5,-6);
                                    Of.Text=string.format('%d',Sg[Ti].speed)
                                end
                            end
                        end)
                    end
                end
            end
        end
        local d_={vd,Sk,ql,Fj,If,kn,Pa,Ee,Zd,je,rd}
        local function Rj(da)
            local M=Instance.new'Frame';
            M.Size=UDim2 .new(1,0,0,34);
            M.BackgroundTransparency=1;
            M.Parent=Fj
            local fg=Ue[da.name]~=nil
            local Qe,Na=fg and(Th=='custom'and-102 or-70)or-70,Instance.new'TextButton';
            Na.Size=UDim2 .new(1,Qe,1,0);
            Na.Position=UDim2 .new(0,0,0,0);
            Na.BackgroundColor3=He.rowBg;
            Na.BackgroundTransparency=Hm.row;
            Na.Text='  '..da.name;
            Na.TextColor3=He.textPrimary;
            Na.TextSize=12;
            Na.Font=Enum.Font.GothamSemibold;
            Na.TextXAlignment=Enum.TextXAlignment.Left;
            Na.BorderSizePixel=0;
            Na.Parent=M
            local w_=Instance.new'UICorner';
            w_.CornerRadius=UDim.new(0,8);
            w_.Parent=Na
            local xi=nil
            if fg and Th=='custom'then
                xi=Instance.new'TextButton';
                xi.Size=UDim2 .new(0,32,1,0);
                xi.Position=UDim2 .new(1,-98,0,0);
                xi.BackgroundTransparency=1;
                xi.Text='X';
                xi.TextColor3=He.textRed;
                xi.TextSize=14;
                xi.BorderSizePixel=0;
                xi.Parent=M
            end
            local Zk=Instance.new'TextButton';
            Zk.Size=UDim2 .new(0,32,1,0);
            Zk.Position=UDim2 .new(1,-66,0,0);
            Zk.BackgroundTransparency=1;
            Zk.Text=me[da.name]and'\226\152\133'or'\226\152\134';
            Zk.TextColor3=me[da.name]and He.textGold or He.textDim;
            Zk.TextSize=16;
            Zk.BorderSizePixel=0;
            Zk.Parent=M
            local Ei=Instance.new'TextButton';
            Ei.Size=UDim2 .new(0,32,1,0);
            Ei.Position=UDim2 .new(1,-32,0,0);
            Ei.BackgroundTransparency=1;
            Ei.Text=Hi[da.name]and(Hi[da.name].Name:gsub('KeyCode%.',''):sub(1,3))or'Bind';
            Ei.TextColor3=Hi[da.name]and He.textPrimary or He.textDim;
            Ei.TextSize=8;
            Ei.Font=Enum.Font.Gotham;
            Ei.BorderSizePixel=0;
            Ei.Parent=M;
            Na.MouseEnter:Connect(function()
                if Rf.currentId~=tostring(da.id)then
                    Na.BackgroundTransparency=Hm.rowH
                end
            end);
            Na.MouseLeave:Connect(function()
                if Rf.currentId~=tostring(da.id)then
                    Na.BackgroundTransparency=Hm.row
                end
            end);
            Na.MouseButton1Click:Connect(function()
                task.spawn(function()
                    Ka(tostring(da.id))
                end)
            end)
            if xi then
                xi.MouseButton1Click:Connect(function()
                    Ue[da.name]=nil;
                    md[da.name]=nil;
                    Hi[da.name]=nil;
                    me[da.name]=nil;
                    Wi();
                    Jl();
                    Ad();
                    loadGUI()
                end)
            end
            Zk.MouseButton1Click:Connect(function()
                if me[da.name]then
                    me[da.name]=nil;
                    Zk.Text='\226\152\134';
                    Zk.TextColor3=He.textDim
                else
                    me[da.name]=tostring(da.id);
                    Zk.Text='\226\152\133';
                    Zk.TextColor3=He.textGold
                end
                Ad()
                if Th=='favorites'then
                    spawn(function()
                        wait(0.10000000000000001);
                        loadGUI()
                    end)
                end
            end);
            Ei.MouseButton1Click:Connect(function()
                if Hi[da.name]then
                    Hi[da.name]=nil;
                    Jl();
                    Ei.Text='Bind';
                    Ei.TextColor3=He.textDim;
                    vd.Text='Unbound '..da.name;
                    vd.TextColor3=He.textRed;
                    spawn(function()
                        wait(2);
                        vd.Text='Ready | '..ud;
                        vd.TextColor3=He.textDim
                    end)
                    return
                elseif not Ob then
                    Ob=true;
                    ne=da.name;
                    vd.Text='Press any key to bind...';
                    vd.TextColor3=He.textYellow;
                    Ei.Text='...'
                    local zj=nil;
                    zj=cb.InputBegan:Connect(function(jc,Lf)
                        if Lf then
                            return
                        elseif Ob and ne==da.name then
                            if jc.KeyCode==Enum.KeyCode.Escape or jc.KeyCode==Enum.KeyCode.Backspace then
                                Ei.Text='Bind';
                                Ei.TextColor3=He.textDim;
                                vd.Text='Binding cancelled';
                                vd.TextColor3=He.textDim;
                                spawn(function()
                                    wait(2);
                                    vd.Text='Ready | '..ud
                                end);
                                Ob=false;
                                ne=nil;
                                zj:Disconnect()
                            elseif jc.KeyCode~=Enum.KeyCode.Unknown then
                                Hi[da.name]=jc.KeyCode;
                                Jl();
                                Ei.Text=jc.KeyCode.Name:gsub('KeyCode%.',''):sub(1,3);
                                Ei.TextColor3=He.textPrimary;
                                vd.Text='Bound -> '..jc.KeyCode.Name:gsub('KeyCode%.','');
                                vd.TextColor3=He.textGreen;
                                spawn(function()
                                    wait(2);
                                    vd.Text='Ready | '..ud;
                                    vd.TextColor3=He.textDim
                                end);
                                Ob=false;
                                ne=nil;
                                zj:Disconnect()
                            end
                        else
                            zj:Disconnect()
                        end
                    end)
                end
            end);
            Hk[da.name]={Container=M,NameButton=Na,FavoriteButton=Zk,KeybindButton=Ei,DeleteButton=xi}
        end
        function loadGUI()
            for bj,uj in pairs(Fj:GetChildren())do
                if uj:IsA'Frame'then
                    uj:Destroy()
                end
            end
            Hk={}
            local oi
            if Th~='custom'then
                oi=false
            else
                oi=tl
            end
            kn.Visible=oi;
            Zd.Visible=Th=='custom';
            Pa.Visible=Th=='states';
            je.Visible=Th=='size';
            rd.Visible=Th=='others';
            Fj.Visible=Th~='states'and Th~='size'and Th~='others';
            ql.Visible=Th~='states'and Th~='size'and Th~='others';
            Ee.Visible=Th=='custom'or Th=='states'
            if Fj.Visible then
                if Th~='custom'then
                    Fj.Size=UDim2 .new(1,-16,1,-175);
                    Fj.Position=UDim2 .new(0,8,0,104)
                elseif tl then
                    Fj.Size=UDim2 .new(1,-16,1,-270);
                    Fj.Position=UDim2 .new(0,8,0,195)
                else
                    Fj.Size=UDim2 .new(1,-16,1,-205);
                    Fj.Position=UDim2 .new(0,8,0,134)
                end
                local Kk,pa,pd={},ql.Text:lower(),Th=='custom'and Ue or md
                for Eg,Fi in pairs(pd)do
                    if(Th~='favorites'or me[Eg]~=nil)and(pa==''or Eg:lower():find(pa))then
                        table.insert(Kk,{name=Eg,id=Fi})
                    end
                end
                table.sort(Kk,function(j,qd)
                    return j.name<qd.name
                end)
                for vi,oj in pairs(Kk)do
                    Rj(oj)
                end
                spawn(function()
                    wait(0.10000000000000001);
                    Fj.CanvasSize=UDim2 .new(0,0,0,Jm.AbsoluteContentSize.Y+10)
                end)
            end
        end
        local n_=false
        local function Yj(sl)
            local bb=math.floor(sl*10+0.5);
            Rf.speed=bb/5;
            Rh.Position=UDim2 .new(sl,-6,0.5,-6);
            Of.Text=string.format('%d',bb)
        end
        local function Eb(Kc)
            Yj(math.clamp((Kc.Position.X-yf.AbsolutePosition.X)/yf.AbsoluteSize.X,0,1))
        end
        local function nl()
            Rf.speed=1;
            Rh.Position=UDim2 .new(0.5,-6,0.5,-6);
            Of.Text='5'
        end
        spawn(function()
            wait(0.10000000000000001);
            Rh.Position=UDim2 .new(0.5,-6,0.5,-6);
            Of.Text='5'
        end);
        yf.InputBegan:Connect(function(oa)
            if oa.UserInputType==Enum.UserInputType.MouseButton1 or oa.UserInputType==Enum.UserInputType.Touch then
                n_=true;
                Eb(oa)
            end
        end);
        cb.InputChanged:Connect(function(fj)
            if n_ and(fj.UserInputType==Enum.UserInputType.MouseMovement or fj.UserInputType==Enum.UserInputType.Touch)then
                Eb(fj)
            end
        end);
        cb.InputEnded:Connect(function(zi)
            if zi.UserInputType==Enum.UserInputType.MouseButton1 or zi.UserInputType==Enum.UserInputType.Touch then
                n_=false
            end
        end);
        Km.MouseButton1Click:Connect(nl);
        Km.MouseEnter:Connect(function()
            Km.BackgroundTransparency=Hm.btnH
        end);
        Km.MouseLeave:Connect(function()
            Km.BackgroundTransparency=Hm.btn
        end);
        nk.MouseButton1Click:Connect(function()
            L()
            if Pg then
                Nk(false)
            end
            _f:Destroy()
        end);
        nk.MouseEnter:Connect(function()
            nk.BackgroundTransparency=Hm.btnH
        end);
        nk.MouseLeave:Connect(function()
            nk.BackgroundTransparency=Hm.btn
        end);
        Ya.MouseButton1Click:Connect(function()
            if not _l then
                _l=true
                if Zm then
                    local yl=Ci:Create(sg,TweenInfo.new(0.20000000000000001,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2 .new(0,315,0,480)});
                    Ya.Text='-';
                    Zm=false;
                    yl:Play();
                    yl.Completed:Connect(function()
                        for _b,Yk in pairs(d_)do
                            if Yk==kn then
                                Yk.Visible=Th=='custom'and tl
                            elseif Yk==Zd then
                                Yk.Visible=Th=='custom'
                            elseif Yk==Pa then
                                Yk.Visible=Th=='states'
                            elseif Yk==je then
                                Yk.Visible=Th=='size'
                            elseif Yk==rd then
                                Yk.Visible=Th=='others'
                            elseif Yk==Ee then
                                Yk.Visible=Th=='custom'or Th=='states'
                            elseif Yk==Fj or Yk==ql then
                                Yk.Visible=Th~='states'and Th~='size'and Th~='others'
                            else
                                Yk.Visible=true
                            end
                        end
                        _l=false
                    end)
                else
                    for sf,Vl in pairs(d_)do
                        Vl.Visible=false
                    end
                    local Ha=Ci:Create(sg,TweenInfo.new(0.20000000000000001,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2 .new(0,315,0,30)});
                    Ya.Text='+';
                    Zm=true;
                    Ha:Play();
                    Ha.Completed:Connect(function()
                        _l=false
                    end)
                end
            end
        end);
        Ya.MouseEnter:Connect(function()
            Ya.BackgroundTransparency=Hm.btnH
        end);
        Ya.MouseLeave:Connect(function()
            Ya.BackgroundTransparency=Hm.btn
        end);
        ql:GetPropertyChangedSignal'Text':Connect(loadGUI)
        local function Vh(hd)
            Th=hd;
            tl=false
            for Ea,Wl in pairs(Hc)do
                if Ea==hd then
                    Wl.BackgroundColor3=He.tabActive;
                    Wl.BackgroundTransparency=Hm.tabA;
                    Wl.TextColor3=He.textPrimary
                else
                    Wl.BackgroundColor3=He.tabIdle;
                    Wl.BackgroundTransparency=Hm.tab;
                    Wl.TextColor3=He.textSecond
                end
            end
            loadGUI()
        end
        for ck,Hf in pairs(Hc)do
            local fn=ck;
            Hf.MouseButton1Click:Connect(function()
                Vh(fn)
            end)
        end
        Zd.MouseButton1Click:Connect(function()
            if tl then
                local vl,rf=dm.Text,kj.Text
                if vl==''or rf==''then
                    vd.Text='Name and code required!';
                    vd.TextColor3=He.textRed;
                    spawn(function()
                        wait(2);
                        vd.Text='Ready | '..ud;
                        vd.TextColor3=He.textDim
                    end)
                    return
                end
                Ue[vl]=rf;
                md[vl]=rf;
                Wi();
                dm.Text='';
                kj.Text='';
                tl=false;
                kn.Visible=false;
                Zd.Text='Add';
                Zd.BackgroundColor3=He.btnBg;
                Fj.Size=UDim2 .new(1,-16,1,-175);
                Fj.Position=UDim2 .new(0,8,0,104);
                vd.Text='Added: '..vl;
                vd.TextColor3=He.textGreen;
                spawn(function()
                    wait(2);
                    vd.Text='Ready | '..ud;
                    vd.TextColor3=He.textDim
                end);
                loadGUI()
            else
                tl=true;
                kn.Visible=true;
                Zd.Text='Save';
                Zd.BackgroundColor3=He.toggleOn;
                Fj.Size=UDim2 .new(1,-16,1,-270);
                Fj.Position=UDim2 .new(0,8,0,195)
            end
        end);
        Zd.MouseEnter:Connect(function()
            Zd.BackgroundTransparency=Hm.btnH
        end);
        Zd.MouseLeave:Connect(function()
            Zd.BackgroundTransparency=Hm.btn
        end)
        local xb,_j,r_=false,nil,nil;
        hh.InputBegan:Connect(function(Bf)
            if Bf.UserInputType==Enum.UserInputType.MouseButton1 or Bf.UserInputType==Enum.UserInputType.Touch then
                xb=true;
                _j=Bf.Position;
                r_=sg.Position
            end
        end);
        cb.InputChanged:Connect(function(Xa)
            if xb and(Xa.UserInputType==Enum.UserInputType.MouseMovement or Xa.UserInputType==Enum.UserInputType.Touch)then
                local y=Xa.Position-_j;
                sg.Position=UDim2 .new(r_.X.Scale,r_.X.Offset+y.X,r_.Y.Scale,r_.Y.Offset+y.Y)
            end
        end);
        cb.InputEnded:Connect(function(wb)
            if wb.UserInputType==Enum.UserInputType.MouseButton1 or wb.UserInputType==Enum.UserInputType.Touch then
                xb=false
            end
        end);
        vd.Text='Loading animations...';
        vd.TextColor3=He.textYellow;
        spawn(function()
            wait(1)
            local jf=0
            for vf in pairs(md)do
                jf=jf+1
            end
            vd.Text='Loaded '..jf..' anims  \226\128\162  '..ud;
            vd.TextColor3=He.textGreen;
            loadGUI();
            spawn(function()
                wait(3);
                vd.Text='Ready | '..ud;
                vd.TextColor3=He.textDim
            end)
        end)
    end
end
cb.InputBegan:Connect(function(jk,mk)
    if mk then
        return
    end
    for Ga,ti in pairs(Hi)do
        if jk.KeyCode==ti then
            local Lc=Ue[Ga]or md[Ga]or me[Ga]
            if Lc then
                Ka(tostring(Lc))
            end
            break
        end
    end
end);
task.spawn(function()
    Cg();
    ag();
    Ud()
end);
print'Custom emotes drop folder: Drop JSON FILES HERE';
print'JSON format: {\"AnimName\":\"animId\"} or [{\"name\":\"AnimName\",\"id\":\"animId\"}]'
