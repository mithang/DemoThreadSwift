// GCD: Grand Central Dispatch
// GCD là một tập hợp thư viện để cải tiến và đơn giản hóa dùng Thread. Chúng ta không còn tạo thread đơn lẽ sau đó start chúng nữa mà chỉ cần, đưa các task(thread) vào trong hàng đợi(queue). Các queue sẽ tự quản lí thread(khởi tạo, chạy và hủy)
//GDP đự trên cơ chết Thread Pool. Đây là cơ chế tối ưu cho việc tạo và hủy thread

//Thread tạo ra nhiều task chạy cùng một lúc

//Dispatch Queues có nhiệm vụ tạo, thực thi và hủy task. Chạy theo cơ chể FIFO(Vào trước, xử lí trước). Có hai loại:
//1.Serial: queue chỉ có duy nhất một thread được chạy tại một thời điểm
//2.Concurrent: Có nhiều thread hơn và có thể chạy song song

//Dispatch Async chạy bắt đồng bộ, không đợi ai, việc ai náy làm
//Dispatch Sync chạy một cách đồng bộ. Dùng khi block thread khi có nhiều thread dùng chung dữ liệu
//Dispatch After: Định thời gian để chạy thread
//DispatchWorkItem bổ sung từ swift 3 không cần viết closure mà chỉ cần dùng class DispatchWorkItem
//Deadlock
//Thread Sanitizer để xem lỗi các thread truy cập cùng lúc
import UIKit
//Chú ý: Cơ chế chạy từ trên xuống dưới theo tuần tự gọi là: blocking FIFO
//Tìm hiểu thêm: https://medium.com/modernnerd-code/grand-central-dispatch-crash-course-for-swift-3-8bf2652c1cb8
//GDC và NSOperation(Operation 4.0) dưới ios 4.0 thì nằm đọc lập và ngược lại. GDC viết bằng Objective-C, nhưng NSOperation được viết thành những đối tượng, kết thừa nó và sau đó dùng nó
//GDC dùng khi muốn làm nhanh implement background
//NSOperationQueue dùng khi muốn điều kiển create, custom và cancel của một task. Và nó là high level hơn GDC
class ViewController: UIViewController {

    @IBOutlet weak var lb: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        //Tạo một hàng đợi thread bằng serial, swift 4 không còn cách tạo này
        //let serialQueue = DispatchQueue(label: "mySerialQueue", attributes:[.serial])
        //Chỉ xử lí một thread đâu tiên
        //let normalQueue = DispatchQueue(label: "mySerialQueue")
        
        //Tạo một hàng đợi thread bằng concurent
        let concurrentQueue = DispatchQueue(label: "myConcurrentQueue", attributes:[.concurrent])
        
        //Các queue có sẳn trong hệ thống
        //let mainQueue = DispatchQueue.main
        //let globalQueue = DispatchQueue.global()
        
        print("Đang xử lí...")
        /*
        for i in 0...1000{
            //Nếu dùng serialQueue.async nó sẽ sử lí từ task 1 đến task 999 theo thứ tự
            //concurrentQueue.async: Chạy  không theo thứ tự 0...999
            concurrentQueue.async {
                print(i)
                sleep(1)
            }
        }
        */

        /*
        var count = 0
        for i in 0...1000{
            //Ta thấy có 1000 task chạy bắt đồng bộ và dùng chung biến count, chạy sẽ sai
            //cách khắc phục là concurrentQueue.sync{}, hoac dung @synchronized 
            concurrentQueue.sync {
                count+=1
                print(i)
            }
        }
        print("Count: \(count)")
        */
        
        /*
        concurrentQueue.asyncAfter(deadline: .now()+5, execute: {
            print("Chạy sau 5s")
        })
        */
        /*
        let task = DispatchWorkItem{
            print("Đã thực thi")
        }
        concurrentQueue.async(execute: task)
        concurrentQueue.asyncAfter(deadline: .now()+5, execute: task)
        */
        
        
        
        /*
         DispatchQueue.main.async {
         var sum=0;
         for i in 0...10{
         sum+=i;
         print("sum: \(sum)")
         }
         //Vì nằm trong hàng đợi block nên có thể truy cập nhiều thread, nên cũng có thể update UI
         self.lb.text=String(sum)
         }
         */
        /*
         Hàm thường dùng DispatchQueue để bắt đồng bộ
         let queue = DispatchQueue(label: "queuegroup")
         queue.async{
             //Xử lí dữ liệu internet
             DispatchQueue.main.async{
                //Cập nhật dữ liệu trên UI chính. Chú ý nếu để hàm bên ngoài sẽ bị deadlock vì hàm main chờ hàm main
             }
         }
         */
        /*
        //DispathGroup: Cho phép quản lí một nhóm các tác vụ
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "queuegroup")
        //Bắt đầu bắm giờ
        group.enter()
        queue.async {
            for i in 0..<200000{
                print("Xử lý: \(i)")
            }
            //Kết thúc bắm giờ
            group.leave()
        }
        //Nếu thời gian 3s mà xử lí xong 20 thì xuất ra success
        //Nếu trong 3s mà không xử lí hết 20 thì sẽ timeout, tuy hết thời gian nhưng vẫn chạy tiếp tục
        let result = group.wait(timeout: DispatchTime.now()+3)
        print(result)
        */
        
        //Bắt đầu xử lí thread pool
        let queue = OperationQueue()
        //Mỗi lần chỉ xử lí một thread, nếu không có thì nó xử lí cùng một lúc hết tất cả
        queue.maxConcurrentOperationCount=4
        for i in 0..<20{
             //C1: Viết bên trong
             //queue.addOperation {
             //    print("Xử lí \(i)")
             //    sleep(1)//Chờ đợi 1s, chú ý java và c# là 1000
             //}
             //C2: Custom Operation
             //queue.addOperation(Op(n: i))
            //C3: Custom Operation
            let op=Op(n: i)
            //Hàm luôn luôn chạy khi thành công hay hủy các task
            op.completionBlock={
                print("Operation \(i), cancelled: \(op.isCancelled)")
            }
            queue.addOperation(op)
            
        }
        //Chạy 5s, sau đó hủy tất cả các task đang làm việc
        sleep(5)
        queue.cancelAllOperations()
        queue.waitUntilAllOperationsAreFinished()
        
        
        //Thread.current.name: Tên thread
        //Thread.current.isMainThread: Thread có phải là main thread hay không
        //Thread.current.isCancelled
        //Thread.current.isExecuting
        //Thread.current.isFinished
        //Khóa các hàng đợi lòng vào nhau
        //blockOperationsTest1()
     
        //sampleCodeOne()
        //sampleCodeTwo()
        print("Kết thúc")
    }
    func sampleCodeOne (){
        //Dùng OperationQueue mặt định
        var operationQueue: OperationQueue = OperationQueue.main
        var completionBlockOperation: BlockOperation = BlockOperation.init(
            block: {
            print("completion Block is getting called")
            }
        )
        
        var workerBlockOperation:BlockOperation = BlockOperation.init(
            block: {
            print("worker block")
            self.sampleCodeOneWorkerMethod()
            }
        )
        //Block completionBlockOperation chạy khi workerBlockOperation đã hoàn thành
        completionBlockOperation.addDependency(workerBlockOperation)
        //Đưa hai block vào hàng đợi
        operationQueue.addOperation(workerBlockOperation)
        operationQueue.addOperation(completionBlockOperation)
    }
    
    func sampleCodeOneWorkerMethod ()
    {
        print("Actual Worker Block")
        for  i in 1..<5
        {
            sleep(1)
            print(i)
        }
        
    }
    func sampleCodeTwo(){
        let customOperation : MyCustomOperation = MyCustomOperation()
        
        customOperation.completionBlock = {
            print("Both the Block Operation and the Custom Operation is completed")
        }
        
        var workerBlockOperation:BlockOperation = BlockOperation.init(
            block: {
                print("Primary Worker block")
            }
        )
        //customOperation được chạy khi workerBlockOperation hoàn thành
        customOperation.addDependency(workerBlockOperation)
        
        let operationQueue = OperationQueue.main
        operationQueue.addOperation(customOperation)
        operationQueue.addOperation(workerBlockOperation)
    }

    func blockOperationsTest1(){
        
        var operationQueue = OperationQueue()
        
        let operation1 : BlockOperation = BlockOperation (block: {
            self.doCalculations()
            
            //Hàng đợi lòng hàng đợi. Cần block chúng lại để cho hàm doCalculations() chạy trước, sau đó tới hàm doSomeMoreCalculations()
            //Nếu đặt doSomeMoreCalculations() đặt bên ngoài thì hai hàng đợi này chạy song song
            let operation2 : BlockOperation = BlockOperation (block: {
                self.doSomeMoreCalculations()
            })
            operationQueue.addOperation(operation2)
        })
        operationQueue.addOperation(operation1)
    }
    
    func doCalculations(){
        NSLog("do Calculations")
        for i in 100...105{
            print("i in do calculations is \(i)")
            sleep(1)
        }
    }
    
    func doSomeMoreCalculations(){
        NSLog("do Some More Calculations")
        for j in 1...5{
            print("j in do some more calculations is \(j)")
            sleep(1)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }


}

class Op:Operation{
    var i: Int
    init(n:Int){
        i=n
    }
    override func main() {
        print("Xử lí: \(i)")
        sleep(2)//Chở đợi 2s để thấy sử lí tứng task riêng lẻ
    }
}
//Chú ý: BlockOperation cũng kết thừa từ Operation
class MyCustomOperation: Operation{
    
    //var isExecuting = false;
    //var isFinished = false;

    override func main() {
        if self.isCancelled {
            return
        }
        else
        {
            NSLog("custom operation work is done here.")
            for i in 0..<5
            {
                print("i%d",i)
                sleep(1)
            }
        }
        self.willChangeValue(forKey: "executing")
        //isExecuting = false
        self.didChangeValue(forKey: "executing")

        self.willChangeValue(forKey: "finished")
        //isFinished = true
        self.didChangeValue(forKey: "finished")

        if(isFinished)
        {
            print("completed")
        }
        else
        {
            print("Not completed")
        }
    }
}
