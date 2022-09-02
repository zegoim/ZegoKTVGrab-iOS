require 'xcodeproj'
require 'json'

# Reference: https://mp.weixin.qq.com/s?__biz=MzIwMTYzMzcwOQ==&mid=2650948536&idx=1&sn=aa0e76498e457c4b1ed2ef31e428c7eb&chksm=8d1c197aba6b906c7b977ee2466e3d33cdcd357f5b075c919614a27837e8da23c8e878780874&js_my_comment=1&scrolltodown=1&key=5e85f2ba5f0147df7b99cc355f0e798dfa4205b0199f3a695b7f04ef4755f938706a9b240a26d3d3bd42c519e1ea6dd5932a57a074f05fb021e609f30ea1dcdf691426297f026a5a0ae9776610389ba1&ascene=0&uin=MTg0NjQ3ODQyMA==&devicetype=iMac+MacBookPro12,1+OSX+OSX+10.12.3+build(16D32)&version=12010310&nettype=WIFI&fontScale=100&pass_ticket=nzLA5S15AM90+jLcdY3EHmbnVkL/uAYclofk1GMg/TQSV3QZW/tyXLsrhFw1vilu

def open_project(project_path)
  Xcodeproj::Project.open(project_path)
end

def save_project(project)
  project.save
end

def find_target_in_project(project, target_name)
  project.targets.find do |t|
    t.to_s == target_name
  end
end

def check_ref_existence(build_phase, file_ref)
  exists = false
  build_phase.files_references.each do |f|
    if f.display_name == file_ref.display_name
      exists = true
      break
    end
  end
  exists
end

def add_framework_to_build_phase(target, framework_ref)
  target_framework_build_phase = target.frameworks_build_phases
  exists = check_ref_existence(target_framework_build_phase, framework_ref)
  unless exists
    puts "[ * ] Target \'#{target.display_name}\' attaching #{framework_ref.display_name} to build phase"
    target_framework_build_phase.add_file_reference(framework_ref, true)
  end
end

def add_framework_to_target(project, target, framework_path)
  framework_ref = nil
  project.frameworks_group.children.each do |child|
    if child.display_name == File.basename(framework_path)
      framework_ref = child
    end
  end
  if framework_ref.nil?
    framework_ref = project.frameworks_group.new_file(framework_path)
  end
  add_framework_to_build_phase(target, framework_ref)
end

def add_frameworks_to_target(project, target_name, framework_paths)
  target = find_target_in_project(project, target_name)
  framework_paths.each do |path|
    add_framework_to_target(project, target, path)
  end
end


def main
  puts "[ * ] Starting to attach frameworks to pod targets..."
  
  pod_project_path = './Pods/Pods.xcodeproj'
  # Path is relative to directory 'Pods/'
  rtc_path = '../KTVGrab/Vendor/ZegoExpressEngine.xcframework'
  im_path = '../KTVGrab/Vendor/ZIM.xcframework'

  pod_project = open_project(pod_project_path)
  
  add_frameworks_to_target(pod_project, 'KTVGrab', [rtc_path, im_path])
  
  save_project(pod_project)
  
  puts "[ * ] Attaching frameworks to pod targets completes!"
end

main
