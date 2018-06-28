import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Injectable()
export class VeiculosService {
    private _loading = false;

    get loading(): boolean {
        return this._loading;
    }

    constructor(private http: HttpClient) { }

    public getVeiculos(qtdVolumesMin: number, qtdVolumesMax: number, pesoMin: number, pesoMax: number, limit: number, offset: number) {
        this._loading = true;

        const promise = this.http.get('/api/veiculos/' + qtdVolumesMin + '/' + qtdVolumesMax + '/' +
            pesoMin + '/' + pesoMax + '/' + limit + '/' + offset + '/').toPromise();

        promise
            .then(() => {
                this._loading = false;
            })
            .catch(() => {
                this._loading = false;
            });

        return promise;
    }
}
